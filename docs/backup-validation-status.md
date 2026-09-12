# Backup Validation Status

> Procedure and commands live in [backup-validation.md](backup-validation.md);
> this file only tracks what has actually been done. Step numbers match.

## NFS ACL Fix (completed)

**Root cause**: TrueNAS datasets use `acltype=nfsv4`. The `everyone@` ACE had no `rwx`,
which denied root on sentinel even with root_squash disabled. ZFS NFSv4 ACLs do not exempt root.

**Fix applied per dataset**:

| Dataset        | Method                                               | Status                                    |
| -------------- | ---------------------------------------------------- | ----------------------------------------- |
| home-assistant | No change needed                                     | ✅ readable                               |
| dawarich       | No change needed                                     | ✅ readable                               |
| immich         | TrueNAS UI (recursive, BASIC Read + inherit)         | ✅ ACL applied, needs remount on sentinel |
| nextcloud      | `find ... \| xargs setfacl -m everyone@:rx:fd:allow` | ✅ ACL applied, needs remount on sentinel |

ACL added to each dataset: `everyone@:r-x-----------:fd-----:allow`

**Pending**: remount immich and nextcloud on sentinel to clear stale NFS cache:

```bash
sudo umount /var/lib/immich && sudo mount /var/lib/immich
sudo umount /var/lib/nextcloud && sudo mount /var/lib/nextcloud
```

---

## Validation Checklist Progress

- [ ] **Pre-deploy B2 connectivity test** — not yet run
- [ ] **Step 1: NFS mounts** — hass/dawarich confirmed; immich/nextcloud blocked pending remount
- [ ] **Step 2: Home Assistant** — SQLite integrity check and hot-copy test not yet run
- [ ] **Step 3: Dawarich** — size confirmed (18M); DB check not yet run
- [ ] **Step 4: Nextcloud** — ACL fixed; content check pending remount
- [ ] **Step 5: Immich** — ACL fixed; DB dump configured in backup.nix; pending remount + deploy + restic init
- [ ] **Step 6: Restic dry runs** — not yet run
- [x] **Step 0: Restic repo init** — no longer a manual step; `initialize = true`
      creates the repository on the first run of each job
- [ ] **Step 7: First real backup** — post-deploy, not yet run
- [ ] **Step 8: Restore spot-check** — post-deploy, not yet run

---

## Open Issues

1. **Immich Postgres DB**: ✅ Resolved. `backup.nix` now runs `pg_dumpall` as the `postgres`
   superuser into `/var/lib/immich/database-backup/immich-database.sql` before each restic
   backup, following the official Immich backup guide. The dump is included in the snapshot
   and removed from disk after. `thumbs/` and `encoded-video/` remain excluded.

   **Remaining operational steps (on sentinel):**
   - Remount: `sudo umount /var/lib/immich && sudo mount /var/lib/immich`
   - Deploy the updated NixOS config
   - Init restic repo (one-time, after sops secrets are live):
     ```bash
     set -a; source /run/secrets/restic-b2-env; set +a
     restic -r s3:s3.us-west-004.backblazeb2.com/buttars-backups init
     ```
   - Trigger and verify first backup:
     ```bash
     systemctl start restic-backups-immich.service
     restic -r s3:s3.us-west-004.backblazeb2.com/buttars-backups snapshots
     restic -r s3:s3.us-west-004.backblazeb2.com/buttars-backups check
     ```

2. **Nextcloud Postgres DB**: ✅ Resolved. It lives in the same local postgres
   cluster as immich on sentinel (`ensureDatabases = [ "nextcloud" "immich" ]`),
   so immich's `pg_dumpall` was already capturing it — inside the _immich_
   snapshot, under a filename claiming to be immich's. The nextcloud job now
   runs its own `pg_dump` into `/var/lib/nextcloud/database-backup/`, so the
   snapshot stands alone.

3. **backup.nix HA sqlite exclude direction**: ✅ Fixed. Was backwards — read
   `modules/capability/backup.nix:32-39`. The job does all the work of making a
   consistent snapshot and then throws it away:
   - `paths = [ "/var/lib/hass" ]` — sweeps in the **live** `home-assistant_v2.db`
   - `backupPrepareCommand` writes a consistent hot copy to `db-backup.sqlite`
   - `exclude = [ "/var/lib/hass/db-backup.sqlite" ]` — **excludes that clean copy**
   - `backupCleanupCommand` deletes it

   Every snapshot therefore held a live SQLite file that may have been mid-write,
   and never the consistent one. The exclude is now inverted — the live DB and
   its `-wal`/`-shm` sidecars are excluded, and `db-backup.sqlite` is kept:

   ```nix
   exclude = [
     "/var/lib/hass/home-assistant_v2.db"
     "/var/lib/hass/home-assistant_v2.db-wal"
     "/var/lib/hass/home-assistant_v2.db-shm"
   ];
   ```
