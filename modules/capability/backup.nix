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
        commonOpts = {
          repository = b2Repo;
          environmentFile = config.sops.secrets.restic-b2-env.path;
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
        };
      in
      {
        sops.secrets.restic-b2-env = { };

        services.restic.backups = {
          home-assistant = commonOpts // {
            paths = [ "/var/lib/hass" ];
            exclude = [ "/var/lib/hass/db-backup.sqlite" ];
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
            paths = [ "/var/lib/nextcloud" ];
          };

          immich = commonOpts // {
            paths = [ "/var/lib/immich" ];
            exclude = [
              "/var/lib/immich/thumbs"
              "/var/lib/immich/encoded-video"
            ];
            backupPrepareCommand = ''
              mkdir -p /var/lib/immich/database-backup
              ${pkgs.sudo}/bin/sudo -u postgres \
                ${config.services.postgresql.package}/bin/pg_dumpall \
                  --clean --if-exists \
                  > /var/lib/immich/database-backup/immich-database.sql
            '';
            backupCleanupCommand = "rm -f /var/lib/immich/database-backup/immich-database.sql";
          };
        };
      };
  };
}
