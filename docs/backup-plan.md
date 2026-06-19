# Backup Plan: Restic on Sentinel → Backblaze B2

## Overview

Run restic from `sentinel` to back up all service data to Backblaze B2. Sentinel already mounts all NFS service directories, making it the natural backup host.

## Prerequisites

- [x] Create B2 bucket (`buttars-backups`, object lock enabled, governance 200 days)
- [x] Create B2 application key (scoped to bucket)
- [x] Add credentials to sops: `restic-b2-env` in `modules/sops/secrets.yaml`
- [x] Generate restic repo password and store in sops + Bitwarden
- [ ] Initialize restic repo: `restic -r s3:s3.us-west-004.backblazeb2.com/buttars-backups init`

## Implementation

### 1. Sops secrets

Already added to `modules/sops/secrets.yaml` as `restic-b2-env`:

```yaml
restic-b2-env: |
  AWS_ACCESS_KEY_ID=<b2-key-id>
  AWS_SECRET_ACCESS_KEY=<b2-app-key>
  RESTIC_PASSWORD=<repo-password>
```

### 2. Pre-backup database dumps

Services with databases that need consistent dumps before backup:

| Service | DB | Dump command |
|---------|-----|------|
| Immich | Postgres | `pg_dump -h localhost immich > /var/lib/immich/db-backup.sql` |
| Nextcloud | Postgres/SQLite | `nextcloud-occ maintenance:mode --on && dump && maintenance:mode --off` |
| Home Assistant | SQLite | `sqlite3 /var/lib/hass/home-assistant_v2.db ".backup /var/lib/hass/db-backup.sqlite"` |

These run as `backupPrepareCommand` in the restic module.

### 3. NixOS module (`modules/features/backup.nix`)

```nix
{ config, pkgs, ... }:
{
  sops.secrets.restic-b2-env = {};

  services.restic.backups.b2 = {
    repository = "s3:s3.us-west-004.backblazeb2.com/buttars-backups";
    environmentFile = config.sops.secrets.restic-b2-env.path;

    paths = [
      "/var/lib/hass"
      "/var/lib/dawarich"
      "/var/lib/nextcloud"
      "/var/lib/immich"
    ];

    exclude = [
      "/var/lib/immich/thumbs"
      "/var/lib/immich/encoded-video"
      "/var/lib/jellyfin"  # replaceable cache/metadata
    ];

    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };

    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 6"
    ];

    backupPrepareCommand = ''
      # Home Assistant
      ${pkgs.sqlite}/bin/sqlite3 /var/lib/hass/home-assistant_v2.db \
        ".backup /var/lib/hass/db-backup.sqlite"

      # Immich (if postgres is on sentinel)
      # ${pkgs.postgresql}/bin/pg_dump -U immich immich > /var/lib/immich/db-backup.sql

      # Nextcloud (if postgres is on sentinel)
      # nextcloud-occ maintenance:mode --on
      # ${pkgs.postgresql}/bin/pg_dump -U nextcloud nextcloud > /var/lib/nextcloud/db-backup.sql
      # nextcloud-occ maintenance:mode --off
    '';

    backupCleanupCommand = ''
      rm -f /var/lib/hass/db-backup.sqlite
    '';
  };
}
```

### 4. Include in sentinel host

```nix
includes = [
  ...
  <aegix/backup>
];
```

## Retention Policy

- 7 daily snapshots
- 4 weekly snapshots
- 6 monthly snapshots

## What's NOT backed up (intentionally)

- `/srv/media/` (movies/shows/music) — large, replaceable, re-downloadable
- Jellyfin metadata/cache — regenerated from media
- qBittorrent downloads — transient
- Gluetun state — ephemeral VPN config

## Monitoring

- [ ] Add systemd `OnFailure=` to send notification on backup failure
- [ ] Periodic `restic check` via separate timer (weekly)

## Restore procedure

```bash
# List snapshots
restic -r s3:s3.us-west-004.backblazeb2.com/buttars-backups snapshots

# Restore specific service
restic restore latest --target /restore --include /var/lib/hass

# Restore specific file
restic restore latest --target /tmp/restore --include /var/lib/hass/db-backup.sqlite
```

## Open Questions

- [ ] Are immich/nextcloud databases on sentinel or inside containers on TrueNAS?
- [ ] Do you want media backed up too (large cost on B2) or just service state?
- [ ] Notification preference: email, ntfy, or something else?
