{
  __findFile,
  aegix,
  lib,
  ...
}:
{
  aegix.backup = {
    nixos =
      { config, pkgs, ... }:
      let
        b2Repo = "s3:s3.us-west-004.backblazeb2.com/buttars-backups";
        dumpDir = "/var/backup";

        # Smallest first, so a long immich run never delays the quick jobs.
        # Order is fixed rather than scheduled: each job ends with a prune,
        # which takes an exclusive repository lock, so they cannot overlap.
        jobOrder = [
          "home-assistant"
          "dawarich"
          "nextcloud"
          "immich"
        ];

        commonOpts = {
          repository = b2Repo;
          environmentFile = config.sops.secrets.restic-b2-env.path;
          initialize = true;
          # null means the module creates no timer; restic-backups.service
          # drives every job in sequence instead.
          timerConfig = null;
          pruneOpts = [
            "--keep-daily 7"
            "--keep-weekly 4"
            "--keep-monthly 6"
          ];
        };
      in
      {
        sops.secrets.restic-b2-env = { };

        services.restic.backups = {
          home-assistant = commonOpts // {
            paths = [ "/var/lib/hass" ];
            # The live database can be captured mid-write; db-backup.sqlite is the
            # consistent copy made below, so that is the one worth keeping.
            exclude = [
              "/var/lib/hass/home-assistant_v2.db"
              "/var/lib/hass/home-assistant_v2.db-wal"
              "/var/lib/hass/home-assistant_v2.db-shm"
            ];
            backupPrepareCommand = ''
              ${pkgs.sqlite}/bin/sqlite3 /var/lib/hass/home-assistant_v2.db \
                ".backup /var/lib/hass/db-backup.sqlite"
            '';
            backupCleanupCommand = "rm -f /var/lib/hass/db-backup.sqlite";
          };

          dawarich = commonOpts // {
            paths = [ "/var/lib/dawarich" ];
          };

          nextcloud = commonOpts // {
            # The dump lands on local disk: /var/lib/nextcloud is an NFSv3 mount
            # where root squashes to nobody and cannot write.
            paths = [
              "/var/lib/nextcloud"
              "${dumpDir}/nextcloud"
            ];
            backupPrepareCommand = ''
              mkdir -p ${dumpDir}/nextcloud
              ${pkgs.sudo}/bin/sudo -u postgres \
                ${config.services.postgresql.package}/bin/pg_dump \
                  --clean --if-exists nextcloud \
                  > ${dumpDir}/nextcloud/nextcloud-database.sql
            '';
            backupCleanupCommand = "rm -f ${dumpDir}/nextcloud/nextcloud-database.sql";
          };

          immich = commonOpts // {
            paths = [
              "/var/lib/immich"
              "${dumpDir}/immich"
            ];
            exclude = [
              "/var/lib/immich/thumbs"
              "/var/lib/immich/encoded-video"
            ];
            backupPrepareCommand = ''
              mkdir -p ${dumpDir}/immich
              ${pkgs.sudo}/bin/sudo -u postgres \
                ${config.services.postgresql.package}/bin/pg_dumpall \
                  --clean --if-exists \
                  > ${dumpDir}/immich/immich-database.sql
            '';
            backupCleanupCommand = "rm -f ${dumpDir}/immich/immich-database.sql";
          };
        };

        systemd.services.restic-backups = {
          description = "Run every restic backup job in sequence";
          serviceConfig.Type = "oneshot";
          script = ''
            status=0
            for job in ${lib.concatStringsSep " " jobOrder}; do
              echo "==> restic-backups-$job"
              if ! ${pkgs.systemd}/bin/systemctl start --wait "restic-backups-$job.service"; then
                echo "!!! restic-backups-$job failed" >&2
                status=1
              fi
            done
            exit $status
          '';
        };

        systemd.timers.restic-backups = {
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = "*-*-* 01:00:00";
            Persistent = true;
          };
        };

        systemd.services.restic-check = {
          description = "Restic repository integrity check";
          serviceConfig = {
            Type = "oneshot";
            EnvironmentFile = config.sops.secrets.restic-b2-env.path;
          };
          script = "${pkgs.restic}/bin/restic --repo ${b2Repo} check --with-cache";
        };

        systemd.timers.restic-check = {
          wantedBy = [ "timers.target" ];
          timerConfig = {
            # Well clear of the 01:00 backup chain.
            OnCalendar = "Sun *-*-* 06:00:00";
            Persistent = true;
          };
        };
      };
  };
}
