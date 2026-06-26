# Backup Validation Checklist

Steps 1–6 run **on sentinel before deploying** the NixOS config (credentials sourced from Bitwarden).
Step 0 (`restic init`) and steps 7–8 run **after the first `nixos-rebuild switch`** so sops secrets are live.
All four service directories are NFS-mounted from `truenas.lan:/mnt/veritas/services/<name>`.

---

## 0. Restic Repo Init (post-deploy, one-time)

`restic init` requires the live sops secret, so run this **after** deploying the config:

```bash
# SSH into sentinel
ssh sentinel

# Source the decrypted sops secret
set -a; source /run/secrets/restic-b2-env; set +a

# Initialize the repo (one-time only)
restic -r s3:s3.us-west-004.backblazeb2.com/buttars-backups init
# Expected: "created restic repository <id> at s3:..."

# Confirm it's accessible
restic -r s3:s3.us-west-004.backblazeb2.com/buttars-backups snapshots
# Expected: "repository opened successfully" + empty snapshot list
```

## Pre-deploy: Test B2 Connectivity (from any machine with credentials)

Before deploying, confirm the B2 key and bucket are reachable using credentials from Bitwarden:

```bash
export AWS_ACCESS_KEY_ID=<b2-key-id>
export AWS_SECRET_ACCESS_KEY=<b2-app-key>
export RESTIC_PASSWORD=<repo-password>
export RESTIC_REPOSITORY=s3:s3.us-west-004.backblazeb2.com/buttars-backups

restic snapshots
# Expected: "Is there a repository at the following location?" (repo not yet inited — that's fine)
# A credentials error here means the B2 key or bucket name is wrong
```

---

## 1. NFS Mounts

```bash
# Confirm all four service mounts are active
mount | grep truenas
# Expected: four lines, one each for hass / dawarich / nextcloud / immich

# Confirm none are empty
ls /var/lib/hass
ls /var/lib/dawarich
ls /var/lib/nextcloud
ls /var/lib/immich
# Each should list files/directories, not an empty prompt

# Quick size check (rough signal the data is there)
du -sh /var/lib/hass /var/lib/dawarich /var/lib/nextcloud /var/lib/immich
```

---

## 2. Home Assistant

```bash
# Confirm the live SQLite database exists
ls -lh /var/lib/hass/home-assistant_v2.db
# Expected: file exists, non-zero size

# Confirm it is a valid SQLite database
sqlite3 /var/lib/hass/home-assistant_v2.db "PRAGMA integrity_check;"
# Expected: "ok"

# Run the exact backupPrepareCommand from backup.nix manually
sqlite3 /var/lib/hass/home-assistant_v2.db \
  ".backup /var/lib/hass/db-backup.sqlite"
# Expected: exits silently (no error)

# Verify the backup file was created and is valid
ls -lh /var/lib/hass/db-backup.sqlite
sqlite3 /var/lib/hass/db-backup.sqlite "PRAGMA integrity_check;"
# Expected: file exists, "ok"

# Clean up (mirrors backupCleanupCommand)
rm -f /var/lib/hass/db-backup.sqlite
```

> **Bug to verify**: `backup.nix` currently **excludes** `db-backup.sqlite` and backs up
> the live `home-assistant_v2.db` directly. The typical pattern is the reverse — back up
> the clean hot-copy and exclude the live file. Confirm this is intentional before deploy.
> If not, change the `exclude` to `[ "/var/lib/hass/home-assistant_v2.db" "/var/lib/hass/home-assistant_v2.db-wal" "/var/lib/hass/home-assistant_v2.db-shm" ]`
> and remove the `exclude` on `db-backup.sqlite`.

---

## 3. Dawarich

```bash
# Confirm data directory has content
ls /var/lib/dawarich
du -sh /var/lib/dawarich

# Check for any database files (Dawarich uses Postgres inside its container;
# verify whether any DB data lands under /var/lib/dawarich or only app state)
find /var/lib/dawarich -name "*.db" -o -name "*.sql" 2>/dev/null
```

> **Note**: No pre-backup DB dump is configured for Dawarich. If the Postgres data
> lives under `/var/lib/dawarich`, a dump step should be added before deploy.

---

## 4. Nextcloud

```bash
# Confirm data directory has content
ls /var/lib/nextcloud
du -sh /var/lib/nextcloud

# Look for the Nextcloud data directory (user files)
ls /var/lib/nextcloud/data 2>/dev/null || echo "data dir not at expected path"

# Look for config file to confirm this is a real Nextcloud install dir
ls /var/lib/nextcloud/config/config.php 2>/dev/null || echo "config not found"
```

> **Open question** (from backup-plan.md): Is the Nextcloud Postgres DB on sentinel
> or inside a container on TrueNAS? If it is accessible from sentinel, add:
>
> ```bash
> # Test DB dump (fill in user/db name)
> pg_dump -h localhost -U nextcloud nextcloud > /tmp/nc-test.sql
> wc -l /tmp/nc-test.sql   # sanity check it has rows
> rm /tmp/nc-test.sql
> ```
>
> If not accessible, the current config (filesystem-only backup) may miss the DB.

---

## 5. Immich

```bash
# Confirm data directory has content
ls /var/lib/immich
du -sh /var/lib/immich

# Confirm the excluded directories exist (so the excludes are meaningful)
ls -d /var/lib/immich/thumbs 2>/dev/null || echo "thumbs dir missing"
ls -d /var/lib/immich/encoded-video 2>/dev/null || echo "encoded-video dir missing"

# Confirm the library/upload directory has your actual photos
ls /var/lib/immich/upload 2>/dev/null || ls /var/lib/immich/library 2>/dev/null || \
  echo "no upload/library dir found — check actual path"
```

> **Open question** (from backup-plan.md): Is the Immich Postgres DB accessible from
> sentinel? If yes, add a pre-backup dump step:
>
> ```bash
> pg_dump -h localhost -U immich immich > /tmp/immich-test.sql
> wc -l /tmp/immich-test.sql
> rm /tmp/immich-test.sql
> ```
>
> If the DB is not backed up, photo metadata (albums, faces, users) will be lost on restore
> even if the raw files survive.

---

## 6. Restic Dry Run (per job)

Once the above checks pass, run each job in dry-run mode before activating the timer.
The `--dry-run` flag scans files and prints stats without uploading anything.

```bash
# Source credentials first (same as step 0)
export AWS_ACCESS_KEY_ID=<b2-key-id>
export AWS_SECRET_ACCESS_KEY=<b2-app-key>
export RESTIC_PASSWORD=<repo-password>
export RESTIC_REPOSITORY=s3:s3.us-west-004.backblazeb2.com/buttars-backups

# Home Assistant
restic backup --dry-run \
  --exclude /var/lib/hass/db-backup.sqlite \
  /var/lib/hass

# Dawarich
restic backup --dry-run /var/lib/dawarich

# Nextcloud
restic backup --dry-run /var/lib/nextcloud

# Immich
restic backup --dry-run \
  --exclude /var/lib/immich/thumbs \
  --exclude /var/lib/immich/encoded-video \
  /var/lib/immich
```

Review the output for:

- Unexpected large directories being included
- Directories that should have content showing 0 files
- Any permission-denied errors

---

## 7. First Real Backup (manual trigger, pre-deploy)

Run one real backup before relying on the systemd timer:

```bash
# Run the home-assistant prepare command, then backup, then cleanup
sqlite3 /var/lib/hass/home-assistant_v2.db \
  ".backup /var/lib/hass/db-backup.sqlite"

restic backup \
  --exclude /var/lib/hass/db-backup.sqlite \
  /var/lib/hass \
  /var/lib/dawarich \
  /var/lib/nextcloud \
  --exclude /var/lib/immich/thumbs \
  --exclude /var/lib/immich/encoded-video \
  /var/lib/immich

rm -f /var/lib/hass/db-backup.sqlite

# Verify snapshot was recorded
restic snapshots
# Expected: one snapshot with paths listed

# Verify repo integrity
restic check
# Expected: "no errors were found"
```

---

## 8. Restore Spot-check

Pick one small file from each service and confirm it restores correctly:

```bash
mkdir -p /tmp/restore-test

# List files in latest snapshot
restic ls latest | grep var/lib/hass | head -20

# Restore a single file
restic restore latest \
  --target /tmp/restore-test \
  --include /var/lib/hass/configuration.yaml
ls /tmp/restore-test/var/lib/hass/configuration.yaml

# Clean up
rm -rf /tmp/restore-test
```

---

## Summary Checklist

- [ ] B2 credentials work (`restic snapshots` succeeds)
- [ ] Restic repo initialized
- [ ] All 4 NFS mounts are active and non-empty
- [ ] HA SQLite DB exists and passes integrity check
- [ ] HA hot-copy backup command runs without error
- [ ] `db-backup.sqlite` exclude direction confirmed as intentional (or fixed)
- [ ] Dawarich DB situation understood (filesystem-only or dump needed)
- [ ] Nextcloud DB situation understood (accessible or not from sentinel)
- [ ] Immich DB situation understood (postgres dump needed or not)
- [ ] Immich exclude dirs (`thumbs`, `encoded-video`) confirmed present
- [ ] Dry run for all four jobs passes without errors
- [ ] First real backup completes and `restic check` passes
- [ ] Restore spot-check succeeds for at least one file
