# Backup Plan: Restic on Sentinel → Backblaze B2

> Design and rationale. The step-by-step validation procedure is in
> [backup-validation.md](backup-validation.md) and live progress in
> [backup-validation-status.md](backup-validation-status.md).
> Recovery procedures are in [restore-runbook.md](restore-runbook.md).

## Overview

Run restic from `sentinel` to back up all service data to Backblaze B2. Sentinel already mounts all NFS service directories, making it the natural backup host.

## Prerequisites

- [x] Create B2 bucket (`buttars-backups`, object lock enabled, governance 200 days)
- [x] Create B2 application key (scoped to bucket)
- [x] Add credentials to sops: `restic-b2-env` in `modules/app/sops/secrets.yaml`
- [x] Generate restic repo password and store in sops + Bitwarden
- [x] ~~Initialize restic repo~~ — automated: every job sets `initialize = true`,
      so restic creates the repository on its first run.

## Implementation

### 1. Sops secrets

Already added to `modules/app/sops/secrets.yaml` as `restic-b2-env`:

```yaml
restic-b2-env: |
  AWS_ACCESS_KEY_ID=<b2-key-id>
  AWS_SECRET_ACCESS_KEY=<b2-app-key>
  RESTIC_PASSWORD=<repo-password>
```

### 2. Pre-backup database dumps

Services with databases that need consistent dumps before backup:

| Service        | DB              | Dump command                                                                          |
| -------------- | --------------- | ------------------------------------------------------------------------------------- |
| Immich         | Postgres        | `pg_dump -h localhost immich > /var/lib/immich/db-backup.sql`                         |
| Nextcloud      | Postgres/SQLite | `nextcloud-occ maintenance:mode --on && dump && maintenance:mode --off`               |
| Home Assistant | SQLite          | `sqlite3 /var/lib/hass/home-assistant_v2.db ".backup /var/lib/hass/db-backup.sqlite"` |

These run as `backupPrepareCommand` in the restic module.

### 3. NixOS module (`modules/capability/backup.nix`)

> **Superseded by what was actually built.** The sketch below proposed a single
> `services.restic.backups.b2` job covering all four paths. The implementation
> instead uses **four independent jobs** — `home-assistant`, `dawarich`,
> `nextcloud`, `immich` — each spreading a shared `commonOpts`. Repository,
> daily timer and retention all match this sketch; the job granularity does not.
>
> Per-job differences worth knowing:
>
> - **immich** carries the `thumbs`/`encoded-video` excludes and a live
>   `pg_dumpall` prepare/cleanup pair (the sketch left those commented out).
> - **home-assistant** does the SQLite hot copy and excludes the live database
>   plus its `-wal`/`-shm` sidecars, so the consistent copy is what gets stored.
> - **nextcloud** runs its own `pg_dump`, so its snapshot is self-contained
>   rather than depending on immich's cluster-wide dump.
> - Every job sets `initialize = true`, so the repository is created on first
>   run, and a weekly `restic-check` timer verifies it.
> - The sketch's `/var/lib/jellyfin` exclude was dropped, correctly — jellyfin
>   runs on theatrum and was never in sentinel's paths.
>
> Read the module for current truth. The sketch is kept for the rationale.

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

- [ ] Add systemd `OnFailure=` to send notification on backup failure — blocked
      on the notification destination in Open Questions; no ntfy/mail/gotify
      exists anywhere in the repo yet.
- [x] Periodic `restic check` via separate timer (weekly) — `restic-check`
      service + timer in `modules/capability/backup.nix`.

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

- [x] ~~Are immich databases on sentinel or inside containers on TrueNAS?~~ —
      answered: `backup.nix:57-63` now runs `pg_dumpall` into
      `/var/lib/immich/database-backup/` before each snapshot and removes it
      after. See [backup-validation-status.md](backup-validation-status.md).
- [x] ~~Nextcloud database~~ — it lives in the same local postgres as immich
      (`ensureDatabases = [ "nextcloud" "immich" ]`), so `pg_dumpall` was already
      capturing it inside the _immich_ snapshot. It now gets its own `pg_dump`
      in the nextcloud job so the snapshot is self-contained.
- [ ] Do you want media backed up too (large cost on B2) or just service state?
- [ ] Notification preference: email, ntfy, or something else?
