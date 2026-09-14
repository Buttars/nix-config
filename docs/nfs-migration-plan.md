# NFS Service User Mapping

> **Follow-on to [nfs-per-service-migration.md](nfs-per-service-migration.md)**,
> which moved service configs onto per-service datasets. This covers the separate
> question of who each export maps to.
>
> **Status: done — every per-service share is mapped to its own service user.**
> The only share left on `maproot` is `cognito`, deliberately; see the last
> section.

## The rule

One rule, no per-service variation:

1. **Export**: set `Mapall User` and `Mapall Group` to the service's TrueNAS
   user. Clear `Maproot` — TrueNAS rejects both on one share.
2. **Dataset**: `chown -R <user>:<group>` the dataset to that same user.
3. **Client**: remount, then start the service.

Both edits, then remount. There is no gap-free ordering: changing the export
first breaks the service until the chown lands, and chowning first breaks it
until the export lands. Do them together and accept seconds of downtime rather
than an indefinite window.

### The client uid does not matter

For ordinary file access the client's local uid is irrelevant. The Linux NFS
client does not decide permission from cached attributes; it issues an `ACCESS`
RPC and the server answers after applying mapall. Sonarr and lidarr both run
under their original local uids (274, 306) against datasets owned by 3002 and
3003 and work correctly.

This is worth stating plainly because it is the opposite of the obvious guess,
and the wrong guess costs an afternoon.

### The exception: systemd-managed state directories

A service whose unit declares `StateDirectory=` is different. Before the service
starts, systemd **chowns** that directory to the service's uid. Over NFS that
chown is refused, and the service dies at `STATE_DIRECTORY` before its first
line of code runs.

`prowlarr` was the only such service. It used `DynamicUser=true`, which allocates
a fresh uid on every start — so there was no uid the dataset could be owned by.
The fix pins it to a static user matching TrueNAS, in
`modules/hosts/torrens/default.nix`:

```nix
users.users.prowlarr.uid = lib.mkForce 3005;
users.groups.prowlarr.gid = lib.mkForce 1005;

systemd.services.prowlarr.serviceConfig = {
  DynamicUser = lib.mkForce false;
  User = "prowlarr";
  Group = "prowlarr";
};
```

With the local uid equal to the dataset owner, systemd finds the ownership
already correct and skips the chown entirely.

Two consequences when converting such a service:

- **NixOS will not renumber an existing user.** It logs `warning: not applying
UID change` and carries on, leaving the old uid in place. Run `usermod -u` and
  `groupmod -g` on the host by hand, as with `hass` and `immich` on sentinel.
- **`DynamicUser` leaves a symlink behind.** `/var/lib/<svc>` points at
  `private/<svc>`, and the mount follows it. Delete the symlink, or the mount
  keeps landing in `/var/lib/private/` and the automount unit keeps the old name.

Check for this before converting anything:

```bash
grep -E "^(DynamicUser|StateDirectory)=" /etc/systemd/system/<svc>.service
```

## Users

Created on TrueNAS with fixed uids. **The gids do not track the uids** past
`jellyfin`, so look them up rather than deriving them.

| Service        | Username    | UID  | GID  |
| -------------- | ----------- | ---- | ---- |
| radarr         | `radarr`    | 3001 | 1001 |
| sonarr         | `sonarr`    | 3002 | 1002 |
| lidarr         | `lidarr`    | 3003 | 1003 |
| bazarr         | `bazarr`    | 3004 | 1004 |
| prowlarr       | `prowlarr`  | 3005 | 1005 |
| qbittorrent    | `qbittorr`  | 3006 | 1006 |
| gluetun        | `gluetun`   | 3007 | 1007 |
| jellyfin       | `jellyfin`  | 3010 | 1008 |
| home-assistant | `hass`      | 3020 | 1009 |
| dawarich       | `dawarich`  | 3021 | 1010 |
| nextcloud      | `nextcloud` | 3030 | 1011 |
| immich         | `immich`    | 3031 | 1012 |

**qbittorrent's username is `qbittorr`** — TrueNAS truncates at 8 characters.
`id qbittorrent` returns `no such user`, which reads like a missing account
rather than a truncated name.

Each service's **primary** group is its own (`lidarr:lidarr`). The shared
`media` group is **gid 8675309**, not 3000, and members hold it as a secondary
group for the shared library under `cognito`. Per-service datasets never use it.

## Containers

A container's uid must match the dataset owner where the application checks
ownership itself. `dawarich`'s postgres refuses to start unless the data
directory is owned by its euid, so the container runs as the TrueNAS uid — see
`modules/hosts/sentinel/dawarich.nix`:

```nix
truenasDawarichUser = "3021:1010";
```

Containers that only read and write files need nothing special: mapall remaps
every container uid, including root, to the service user.

## Procedure

On TrueNAS:

```bash
id <service>                                        # confirm the name and uid
chown -R <user>:<group> /mnt/veritas/services/<svc>
```

`Operation not supported` on `.zfs` and `.zfs/snapshot` is expected — those are
read-only snapshot directories. Harmless.

Then set the share's **Mapall User/Group** in the UI (Sharing → Unix (NFS)
Shares → Advanced Options) and clear Maproot. **Never edit `/etc/exports` by
hand** — TrueNAS regenerates it from its config database, so the change survives
until the next share edit or reboot and then silently reverts.

On the client:

```bash
sudo systemctl stop <svc> var-lib-<svc>.automount
sudo systemctl start var-lib-<svc>.automount <svc>
```

**Stop the `.automount` unit, not just `umount`.** With `x-systemd.automount`
anything touching the path remounts it instantly, so a bare `umount` appears to
succeed while the old mapping stays cached. A stale mount reporting old
ownership is the single most misleading state in this whole exercise — it makes
a correct configuration look broken.

If the service already hit its restart limit, `systemctl reset-failed <svc>`
first, or systemd will not retry and the journal will show no new attempt.

**Restart anything sharing the service's network namespace.** On torrens,
`qbittorrent` and `byparr` use `networks = [ "container:gluetun" ]`. Restarting
gluetun destroys that namespace and podman does not reattach them — stop them
first, start them after. Gluetun also pushes its forwarded port into
qbittorrent's API on startup, so if qbittorrent is not yet up that push fails
and qbittorrent keeps a stale listen port.

## Verifying

From an unprivileged account on the client:

```bash
touch /var/lib/<svc>/.probe && stat -c '%u:%g' /var/lib/<svc>/.probe && rm /var/lib/<svc>/.probe
```

Mapall is working if the write succeeds **and** the file lands owned by the
service uid rather than yours. This does not work for a path under
`/var/lib/private/`, which is mode `0700 root:root` — the denial comes from the
parent directory before NFS is consulted, and says nothing about the mapping.

### Failure signatures

| Symptom                                        | Meaning                                          |
| ---------------------------------------------- | ------------------------------------------------ |
| `Input/output error` at `STATE_DIRECTORY`      | Cannot traverse the dataset; mapping not applied |
| `Operation not permitted` at `STATE_DIRECTORY` | Mapping works; systemd's chown refused           |
| SQLite `errno 13` / `lstat ... denied`         | Export maps to the wrong user                    |
| Postgres `data directory has wrong ownership`  | Container uid ≠ dataset owner                    |
| Ownership changes after a remount              | The earlier reading was a stale mount            |

**A service can stay healthy for hours after its mapping breaks**, because open
file descriptors keep working. It then dies at the next restart or reboot — a
moment with no apparent connection to the cause. After converting a host, reboot
it deliberately rather than discovering this later.

## Host restriction

Every line in `/etc/exports` is restricted to the host that needs it. `nextcloud`
and `immich` were the last two exported to everyone; both are now pinned to
`sentinel.lan`.

This matters more once mapall is in place, not less. Mapall remaps every
incoming uid to the service user, so an unrestricted share hands full read/write
as that user to anything on the LAN that mounts it — the mapping that makes the
service work also removes the need to guess a uid.

A note on what was replaced: `maproot=<service>:<service>` looks like the same
thing as mapall but is a halfway state. It remaps only uid 0, so it works while
the service happens to run as root and breaks quietly if that ever changes.

## cognito — needs a decision

`cognito` is mounted at **`/srv` on three hosts** (`torrens`, `sentinel`,
`theatrum`) and holds the shared media library and downloads. It is a shared
area, not a per-service dataset, so the rule above does not apply: one mapall
user would have to serve three hosts' workloads.

It is also why per-service mapping is safe. Hardlinks and atomic moves between
qbittorrent and the `*arr` stack all happen inside `/srv`, untouched by any
per-service dataset change.

Options:

- leave it on `maproot` as the deliberate shared mount;
- give it an unprivileged `srv` user, after confirming nothing writes as root;
- split per host, if the three use disjoint subtrees.

The `media` group (8675309) exists for exactly this share, which argues for
keeping it group-based rather than mapping it to one user.
