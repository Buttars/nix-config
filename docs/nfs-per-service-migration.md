# NFS Per-Service Migration Plan

## Current State

- One ZFS dataset: `veritas/cognito` (12.5T) — media + downloads
- One broad NFS export → `/srv` on torrens, theatrum, sentinel
- Service configs on **local** `/var/lib/` (torrens) or `/srv/services/` (theatrum/jellyfin)

## Target State

- `veritas/services/<name>` — separate ZFS dataset per service (future: move to SSD pool)
- `veritas/cognito` — media + downloads, unchanged (hardlink requirement)
- Per-service NFS exports restricted to the host that needs them
- Service configs mounted from NFS at `/var/lib/<service>` on each host

### Future SSD Migration Path

When SSDs are added, create a `fast` pool and migrate with:

```bash
zfs send -R veritas/services | zfs receive fast/services
```

Then update NFS exports — NixOS mount paths stay the same.

---

## Status

- [x] Phase 1 — Stop everything
- [x] Phase 2 — TrueNAS: create ZFS datasets
- [x] Phase 3 — TrueNAS: create NFS exports
- [ ] Phase 4 — Data migration (local → NFS)
- [ ] Phase 5 — NixOS config changes
- [ ] Phase 6 — Deploy all hosts
- [ ] Phase 7 — TrueNAS snapshot schedules

---

## Phase 1 — Stop Everything ✓

- Shut down theatrum and torrens VMs
- On sentinel: stop home-assistant and dawarich containers

---

## Phase 2 — TrueNAS: Create ZFS Datasets ✓

Datasets created at `veritas/services/<name>` (not under cognito).

```bash
zfs create veritas/services
zfs create veritas/services/radarr
zfs create veritas/services/sonarr
zfs create veritas/services/lidarr
zfs create veritas/services/prowlarr
zfs create veritas/services/bazarr
zfs create veritas/services/qbittorrent
zfs create veritas/services/gluetun
zfs create veritas/services/jellyfin
zfs create veritas/services/home-assistant
zfs create veritas/services/dawarich
```

Ownership set to match service UIDs:

```bash
chown -R 275:275     /mnt/veritas/services/radarr
chown -R 274:274     /mnt/veritas/services/sonarr
chown -R 306:306     /mnt/veritas/services/lidarr
chown -R 61654:61654 /mnt/veritas/services/prowlarr
chown -R 995:992     /mnt/veritas/services/bazarr
chown -R 1000:1000   /mnt/veritas/services/qbittorrent
chown -R 998:998     /mnt/veritas/services/jellyfin
chown -R 286:286     /mnt/veritas/services/home-assistant
# gluetun and dawarich: leave as root
```

### Pinned UIDs (committed to NixOS config)

| Service     | Host     | UID   | GID   |
| ----------- | -------- | ----- | ----- |
| radarr      | torrens  | 275   | 275   |
| sonarr      | torrens  | 274   | 274   |
| lidarr      | torrens  | 306   | 306   |
| prowlarr    | torrens  | 61654 | 61654 |
| bazarr      | torrens  | 995   | 992   |
| qbittorrent | torrens  | 1000  | 1000  |
| gluetun     | torrens  | 0     | 0     |
| jellyfin    | theatrum | 998   | 998   |
| hass        | sentinel | 286   | 286   |
| dawarich    | sentinel | 0     | 0     |

---

## Phase 3 — TrueNAS: Create NFS Exports ✓

One export per service dataset, restricted to the host that needs it.
Authorized hosts use DNS hostnames (`.lan`).

| Export path                       | Authorized host |
| --------------------------------- | --------------- |
| `veritas/services/radarr`         | torrens.lan     |
| `veritas/services/sonarr`         | torrens.lan     |
| `veritas/services/lidarr`         | torrens.lan     |
| `veritas/services/prowlarr`       | torrens.lan     |
| `veritas/services/bazarr`         | torrens.lan     |
| `veritas/services/qbittorrent`    | torrens.lan     |
| `veritas/services/gluetun`        | torrens.lan     |
| `veritas/services/jellyfin`       | theatrum.lan    |
| `veritas/services/home-assistant` | sentinel.lan    |
| `veritas/services/dawarich`       | sentinel.lan    |

NFS export settings:

- All dirs: unchecked
- Maproot/Mapall: leave all empty (UID passthrough)

The existing `veritas/cognito` export is kept for media/downloads (torrens + theatrum).

---

## Phase 4 — Data Migration (Local → NFS)

Stop services on each host before migrating. Mount each NFS share temporarily,
rsync local data in, then unmount.

### Torrens

```bash
mkdir -p /mnt/tmp
for svc in radarr sonarr lidarr prowlarr bazarr qbittorrent gluetun; do
  mkdir -p /mnt/tmp/$svc
  mount -t nfs truenas.lan:/mnt/veritas/services/$svc /mnt/tmp/$svc
  rsync -a /var/lib/$svc/ /mnt/tmp/$svc/
  umount /mnt/tmp/$svc
done
```

### Theatrum

Jellyfin data is already on NFS at `/srv/services/jellyfin` (via the broad cognito mount).
Rsync into the new per-service dataset:

```bash
mkdir -p /mnt/tmp/jellyfin
mount -t nfs truenas.lan:/mnt/veritas/services/jellyfin /mnt/tmp/jellyfin
rsync -a /srv/services/jellyfin/ /mnt/tmp/jellyfin/
umount /mnt/tmp/jellyfin
```

### Sentinel (home-assistant)

```bash
mkdir -p /mnt/tmp/hass
mount -t nfs truenas.lan:/mnt/veritas/services/home-assistant /mnt/tmp/hass
rsync -a /var/lib/hass/ /mnt/tmp/hass/
umount /mnt/tmp/hass
```

### Sentinel (dawarich)

Dawarich uses named Docker volumes. Migrate each into subdirs of the NFS mount:

```bash
mkdir -p /mnt/tmp/dawarich
mount -t nfs truenas.lan:/mnt/veritas/services/dawarich /mnt/tmp/dawarich
for vol in db public watched storage; do
  mkdir -p /mnt/tmp/dawarich/$vol
  docker run --rm \
    -v dawarich-$vol:/src \
    -v /mnt/tmp/dawarich/$vol:/dst \
    alpine sh -c "cp -a /src/. /dst/"
done
umount /mnt/tmp/dawarich
```

---

## Phase 5 — NixOS Config Changes

### Torrens

- Add `fileSystems` entries mounting each service dataset at `/var/lib/<service>`
- Remove `systemd.tmpfiles.rules` entries for dirs that become NFS mounts
- Update qbittorrent container volume to use `/var/lib/qbittorrent` (already correct)
- Extract shared NFS options into a `let` binding

### Theatrum

- Replace broad `/srv` mount with per-service jellyfin mount at `/var/lib/jellyfin`
- Update `services.jellyfin.dataDir` → `/var/lib/jellyfin/data`
- Update `services.jellyfin.configDir` → `/var/lib/jellyfin/config`

### Sentinel

- Add `fileSystems` mount for home-assistant at `/var/lib/hass`
- Add `fileSystems` mount for dawarich at `/var/lib/dawarich`
- Update dawarich container volumes to use bind-mount paths from `/var/lib/dawarich/`
  instead of named Docker volumes
- Remove or narrow existing broad `/srv` mount

---

## Phase 6 — Deploy All Hosts

Deploy in order, verifying each before moving on:

1. **sentinel** — home-assistant and dawarich
2. **theatrum** — jellyfin
3. **torrens** — all arr apps, qbittorrent, gluetun

For each host after deploy:

```bash
mount | grep nfs           # confirm NFS mounts are active
ls -la /var/lib/<service>  # confirm correct ownership
systemctl status <service> # confirm service started cleanly
```

---

## Phase 7 — TrueNAS Snapshot Schedules

Set up per-dataset ZFS snapshot schedules independently for each service dataset.
Configure in TrueNAS UI under Data Protection → Periodic Snapshot Tasks.

Suggested schedule:

| Frequency | Retention    |
| --------- | ------------ |
| Hourly    | 24 snapshots |
| Daily     | 7 snapshots  |
| Weekly    | 4 snapshots  |

---

## Troubleshooting: NFSv4 ACL blocks writes to new files/dirs

Hit on the `immich` dataset on 2026-08-04. Same class of dataset as everything above, so any of them could show this symptom in the future.

**Symptom**: a service throws `EACCES`/`Operation not permitted` writing _newly created_ files or directories under its `/var/lib/<service>` NFS mount, even though `ls -la` shows the directory owned by the correct service user with normal-looking permissions. A one-off `chmod` fixes existing files, but new files keep coming back broken — that's the tell that this is ACL inheritance, not a one-time permission mistake.

**Root cause**: the ZFS dataset's NFSv4 ACL has an inheritable ACE that doesn't grant the owner write on new children. Two forms seen:

- `owner@` has no inherit flags (`-------` instead of `fd-----`/`fdi----`), so new objects never inherit owner write.
- An inheritable `everyone@` ACE grants only `r-x` and is the only thing that propagates, so every new object is born read-only.

### Diagnose

Linux `getfacl` on the NFS client doesn't show NFSv4 ACL detail — check from TrueNAS directly (`ssh root@truenas.lan`):

```
getfacl /mnt/veritas/services/<name>
```

Check whether `owner@` has `fd`/`fdi` inherit flags, and whether any inheritable `everyone@` ACE is read-only-or-less and would be the only thing new objects inherit.

Confirm with a real test as the service's own user:

```
su -m <service-user> -c "mkdir -p /mnt/veritas/services/<name>/.permtest && touch /mnt/veritas/services/<name>/.permtest/f"
stat -f "%Op %Su:%Sg %N" /mnt/veritas/services/<name>/.permtest/f
rm -rf /mnt/veritas/services/<name>/.permtest
```

### Fix

Don't hand-edit NFSv4 ACEs with `setfacl` recursively — one mistake recurses over the whole tree. Use TrueNAS's UI instead:

**Storage → Pools → veritas → services/\<name\> (dataset) → Edit Permissions**

- Give `owner@` (and `group@`) full permissions with `fd` inherit flags.
- Remove/fix any inheritable `everyone@` ACE that grants only read — a zero-permission inheritable `everyone@` entry is harmless (grants nothing, doesn't restrict `owner@`).
- Check **"Apply permissions recursively"** and run it.
- Re-run the diagnose steps to confirm.

### Audit (2026-08-04)

| Dataset          | `owner@` inherit flags                    | Status                                       |
| ---------------- | ----------------------------------------- | -------------------------------------------- |
| `immich`         | none — broken                             | Fixed via Edit Permissions + recursive apply |
| `nextcloud`      | n/a — `everyone@` grants full rwx inherit | Fine (loose, not blocking)                   |
| `home-assistant` | `fdi` inherit-only, full rwx              | Fine                                         |
| `dawarich`       | `fd`, full rwx                            | Fine                                         |

No action needed on nextcloud/home-assistant/dawarich unless one starts showing the same symptom — then follow Diagnose/Fix above.

---

## TODO: hass / nextcloud UID/GID mismatch on sentinel (found 2026-08-04)

`nixos-rebuild switch` on sentinel warns:

```
warning: not applying GID change of group 'hass' (1009 -> 286) in /etc/group
warning: not applying GID change of group 'nextcloud' (1011 -> 992) in /etc/group
warning: not applying UID change of user 'hass' (3020 -> 286) in /etc/passwd
warning: not applying UID change of user 'nextcloud' (3030 -> 994) in /etc/passwd
```

The config declares `hass` at uid/gid 286/286 (`modules/hosts/sentinel/default.nix:101-102`)
and `nextcloud` at uid 994 / gid 992 (`modules/hosts/sentinel/nextcloud.nix:34-35`), but the
live system still has them at the old ids (`hass` 3020:1009, `nextcloud` 3030:1011). NixOS
refuses to auto-change UID/GID of an existing account (safety guard) — hence the warning
instead of a silent, dangerous rewrite.

Confirmed the data hasn't moved either — TrueNAS still owns both datasets at the _old_
numeric ids:

- `/mnt/veritas/services/home-assistant` → 3020:1009 (needs → 286:286)
- `/mnt/veritas/services/nextcloud` → 3030:1011 (needs → 994:992)

There's also a local (non-NFS) path tied to the old nextcloud gid: `/var/lib/redis-nextcloud`
(owned 3030:1011, mode 700).

**Not yet fixed.** Both sides (TrueNAS ownership and sentinel's local passwd/group) must move
together — changing one without the other recreates the same class of problem as the immich
ACL incident above (files owned by a numeric id that no longer resolves to the right user).

Fix, when ready:

1. Stop affected services on sentinel: `home-assistant`, `phpfpm-nextcloud`, `redis-nextcloud`.
2. On TrueNAS: `chown -R 286:286 /mnt/veritas/services/home-assistant` and
   `chown -R 994:992 /mnt/veritas/services/nextcloud`.
3. On sentinel: `groupmod -g 286 hass && usermod -u 286 hass`,
   `groupmod -g 992 nextcloud && usermod -u 994 nextcloud`,
   `chown -R 994:992 /var/lib/redis-nextcloud`.
4. Restart the services, then re-run `nixos-rebuild switch` to confirm the warnings are gone.
