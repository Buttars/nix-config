# Restore Runbook

How to get service data back from the restic repository on Backblaze B2. Written
to be followed under pressure: every command is copy-pasteable and states what it
touches.

Design and rationale live in [backup-plan.md](backup-plan.md). This file is only
about recovery.

## Before you start

| Thing         | Where it is                                         |
| ------------- | --------------------------------------------------- |
| Repository    | `s3:s3.us-west-004.backblazeb2.com/buttars-backups` |
| Credentials   | `/run/secrets/restic-b2-env` on sentinel (sops)     |
| Repo password | same file, `RESTIC_PASSWORD` — also in Bitwarden    |
| Retention     | 7 daily, 4 weekly, 6 monthly                        |
| Jobs          | `home-assistant`, `dawarich`, `nextcloud`, `immich` |

**Without `RESTIC_PASSWORD` the repository cannot be read by anyone, including
you.** If sentinel is gone, get it from Bitwarden before anything else.

`restic` is deliberately not on `PATH`. The setup block below pulls the exact
binary the backup jobs use.

## Step 0 — get a working restic shell

On sentinel, as root:

```bash
sudo -i
RESTIC=$(systemctl cat restic-backups-immich.service | grep -om1 '/nix/store/[^ ]*restic[^ ]*/bin/restic')
set -a; . /run/secrets/restic-b2-env; set +a
export RESTIC_REPOSITORY=s3:s3.us-west-004.backblazeb2.com/buttars-backups
$RESTIC snapshots
```

If sentinel is unavailable, any machine works — install restic, export
`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `RESTIC_PASSWORD` and
`RESTIC_REPOSITORY` by hand from Bitwarden.

## Step 1 — find the snapshot

```bash
$RESTIC snapshots                                  # all jobs
$RESTIC snapshots --path /var/lib/immich           # one service
$RESTIC ls latest --path /var/lib/hass | head -50  # what is in it
$RESTIC find --path /var/lib/immich 'IMG_1234*'    # locate a specific file
```

`latest` is the newest snapshot **across all jobs**, which is rarely what you
want. Always pass `--path` or an explicit snapshot ID.

## Step 2 — restore

Always restore to scratch first, inspect, then move into place. Restoring
straight over live data while a service is running corrupts both.

```bash
mkdir -p /tmp/restore
$RESTIC restore <SNAPSHOT_ID> --target /tmp/restore --include /var/lib/hass/configuration.yaml
```

The restored tree appears under `/tmp/restore` with its full original path, e.g.
`/tmp/restore/var/lib/hass/configuration.yaml`.

---

## Single file (the common case)

```bash
$RESTIC restore <SNAPSHOT_ID> --target /tmp/restore --include <FULL_PATH>
cp /tmp/restore/<FULL_PATH> <FULL_PATH>
```

No service restart needed for config files most services re-read, but restart if
in doubt.

## Home Assistant

Data lives on NFS at `/var/lib/hass`. The backup contains `db-backup.sqlite` —
the consistent hot copy — **not** the live `home-assistant_v2.db`, which is
excluded on purpose.

```bash
systemctl stop home-assistant

$RESTIC restore <SNAPSHOT_ID> --target /tmp/restore --path /var/lib/hass

# verify the database before trusting it
sqlite3 /tmp/restore/var/lib/hass/db-backup.sqlite "PRAGMA integrity_check;"   # expect: ok

# config and state
cp -a /tmp/restore/var/lib/hass/. /var/lib/hass/

# the hot copy becomes the live database
mv /var/lib/hass/db-backup.sqlite /var/lib/hass/home-assistant_v2.db
rm -f /var/lib/hass/home-assistant_v2.db-wal /var/lib/hass/home-assistant_v2.db-shm

systemctl start home-assistant
```

Deleting the stale `-wal`/`-shm` sidecars matters — SQLite will try to replay
them against a database they do not belong to.

## Dawarich

Plain data directory, no database dump of its own.

```bash
systemctl stop dawarich          # or: docker compose down, depending on how it runs
$RESTIC restore <SNAPSHOT_ID> --target /tmp/restore --path /var/lib/dawarich
cp -a /tmp/restore/var/lib/dawarich/. /var/lib/dawarich/
systemctl start dawarich
```

## Nextcloud

Two parts: the data directory on NFS, and a PostgreSQL database on sentinel. The
dump is at `/var/backup/nextcloud/nextcloud-database.sql`, made with
`pg_dump --clean --if-exists nextcloud`.

```bash
systemctl stop nextcloud phpfpm-nextcloud nginx

$RESTIC restore <SNAPSHOT_ID> --target /tmp/restore --path /var/lib/nextcloud

# files
cp -a /tmp/restore/var/lib/nextcloud/. /var/lib/nextcloud/

# database — --clean drops and recreates objects inside the nextcloud DB
sudo -u postgres psql -d nextcloud -f /tmp/restore/var/backup/nextcloud/nextcloud-database.sql

systemctl start postgresql nextcloud phpfpm-nextcloud nginx
nextcloud-occ maintenance:mode --off
nextcloud-occ files:scan --all
```

`files:scan` reconciles the database against what is actually on disk. Skip it
and Nextcloud will show files that are not there, or miss files that are.

## Immich

Same shape: data on NFS, database on sentinel. **Read the warning below before
running the database step.**

```bash
systemctl stop immich-server immich-machine-learning

$RESTIC restore <SNAPSHOT_ID> --target /tmp/restore --path /var/lib/immich
cp -a /tmp/restore/var/lib/immich/. /var/lib/immich/
```

> **The immich dump is `pg_dumpall`, not `pg_dump immich`.** It contains the
> entire PostgreSQL cluster — roles, `immich` **and** `nextcloud`. Restoring it
> wholesale will overwrite the live Nextcloud database with whatever it held at
> backup time.
>
> Only restore the whole cluster during a full rebuild. To recover immich alone,
> extract just its section first:

```bash
# inspect what databases the dump contains
grep -n '^\\connect' /tmp/restore/var/backup/immich/immich-database.sql

# whole cluster — ONLY on a fresh/rebuilt host
sudo -u postgres psql -f /tmp/restore/var/backup/immich/immich-database.sql

# immich only — on a live host with nextcloud running
sed -n '/^\\connect immich/,/^\\connect /p' \
  /tmp/restore/var/backup/immich/immich-database.sql > /tmp/immich-only.sql
sudo -u postgres psql -d immich -f /tmp/immich-only.sql
```

```bash
systemctl start immich-server immich-machine-learning
```

`thumbs/` and `encoded-video/` are excluded from backups by design. Immich
regenerates both; expect thumbnails to rebuild over the following hours.

---

## Full sentinel rebuild

1. Reinstall NixOS and deploy: `just deploy sentinel` from the config repo.
2. Confirm sops secrets are present — `/run/secrets/restic-b2-env` must exist.
3. Confirm the NFS mounts are up: `df -h /var/lib/immich /var/lib/nextcloud /var/lib/hass /var/lib/dawarich`.
4. Restore the cluster database first (`pg_dumpall`, see immich section), since it
   carries roles that both services need.
5. Restore each service's data directory.
6. Start services one at a time and check logs before moving on.

If the NFS data is intact — the usual case, since it lives on truenas rather than
sentinel — steps 4 and 6 are all that is needed. The service directories are
mounted from truenas, not stored on sentinel.

## Verify

```bash
$RESTIC check                    # repository integrity
$RESTIC stats latest             # size of a snapshot
$RESTIC diff <SNAP_A> <SNAP_B>   # what changed between two
```

Clean up scratch when done — restores can be large:

```bash
rm -rf /tmp/restore
```

## Gotchas

- **Prune holds an exclusive lock.** Each job runs `forget --prune` after its
  backup, so jobs cannot run concurrently, and a restore during a running backup
  may block. `$RESTIC unlock` clears a stale lock — only after confirming no job
  is actually running.
- **`latest` spans all four jobs.** Always pair it with `--path`.
- **Root writes to NFS only because of maproot.** The exports map root to each
  service's user; if a restore gets permission denied on `/var/lib/*`, that
  mapping is the thing to check.
- **Object lock is on with 200-day governance retention.** Deleted snapshots keep
  occupying billable B2 space until it expires.
- **No alerting on failure.** Nothing tells you a backup broke — these jobs
  failed silently for days before anyone noticed. Check
  `systemctl list-units 'restic-*' --failed` periodically.
