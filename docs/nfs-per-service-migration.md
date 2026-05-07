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
