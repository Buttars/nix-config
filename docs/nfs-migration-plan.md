# NFS Service User Migration Plan

Migrate all service NFS shares from `maproot: root/wheel` to per-service `mapall_user` mappings.
Each service user was created with a fixed UID on TrueNAS. The `media` group (GID 3000) is shared
by all arr stack services and jellyfin so they can access the shared media library.

## Users Created

| Service | Username | UID | Group |
|---------|----------|-----|-------|
| radarr | `radarr` | 3001 | media |
| sonarr | `sonarr` | 3002 | media |
| lidarr | `lidarr` | 3003 | media |
| bazarr | `bazarr` | 3004 | media |
| prowlarr | `prowlarr` | 3005 | media |
| qbittorrent | `qbittorrent` | 3006 | media |
| gluetun | `gluetun` | 3007 | — |
| jellyfin | `jellyfin` | 3010 | media |
| home-assistant | `hass` | 3020 | — |
| dawarich | `dawarich` | 3021 | — |
| nextcloud | `nextcloud` | 3030 | — |
| immich | `immich` | 3031 | — |

## Phase 1 — torrens.lan (arr stack)

- [ ] Stop all services on `torrens.lan` (radarr, sonarr, lidarr, bazarr, prowlarr, qbittorrent, gluetun)
- [ ] chown datasets:
  ```bash
  chown -R radarr:media /mnt/veritas/services/radarr
  chown -R sonarr:media /mnt/veritas/services/sonarr
  chown -R lidarr:media /mnt/veritas/services/lidarr
  chown -R bazarr:media /mnt/veritas/services/bazarr
  chown -R prowlarr:media /mnt/veritas/services/prowlarr
  chown -R qbittorrent:media /mnt/veritas/services/qbittorrent
  chown -R gluetun:gluetun /mnt/veritas/services/gluetun
  ```
- [ ] Update each NFS share: remove `maproot`, set `mapall_user` to the matching service user
- [ ] Restart services on `torrens.lan`

## Phase 2 — sentinel.lan

- [ ] Stop `home-assistant` and `dawarich`
- [ ] chown datasets:
  ```bash
  chown -R hass:hass /mnt/veritas/services/home-assistant
  chown -R dawarich:dawarich /mnt/veritas/services/dawarich
  ```
- [ ] Update NFS shares: set `mapall_user: hass` and `mapall_user: dawarich`
- [ ] Restart services

## Phase 3 — theatrum.lan

- [ ] Stop `jellyfin`
- [ ] chown dataset:
  ```bash
  chown -R jellyfin:media /mnt/veritas/services/jellyfin
  ```
- [ ] Update NFS share: set `mapall_user: jellyfin`
- [ ] Restart jellyfin

## Phase 4 — unrestricted shares (nextcloud, immich)

- [ ] Stop nextcloud and immich wherever they run
- [ ] chown datasets:
  ```bash
  chown -R nextcloud:nextcloud /mnt/veritas/services/nextcloud
  chown -R immich:immich /mnt/veritas/services/immich
  ```
- [ ] Update NFS shares: set `mapall_user` per service
- [ ] Restart services

## Phase 5 — cognito (needs decision)

The `cognito` share is the most permissive: `mapall: root/wheel`, no host restriction.
Needs clarification on what this share is used for before migrating.
