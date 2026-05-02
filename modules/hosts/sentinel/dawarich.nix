{ __findFile, ... }:
{
  den.aspects.sentinel = {
    nixos =
      {
        pkgs,
        lib,
        config,
        ...
      }:
      {
        virtualisation.docker.enable = true;
        virtualisation.docker.daemon.settings.iptables = false;

        sops.secrets."dawarich/env" = { };

        systemd.services = {
          init-dawarich-network = {
            description = "Create Docker network for Dawarich";
            after = [ "docker.service" ];
            requires = [ "docker.service" ];
            wantedBy = [ "multi-user.target" ];
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
            };
            script = ''
              ${pkgs.docker}/bin/docker network inspect dawarich >/dev/null 2>&1 \
                || ${pkgs.docker}/bin/docker network create dawarich
            '';
          };
        }
        //
          lib.genAttrs
            [
              "docker-dawarich-db"
              "docker-dawarich-redis"
              "docker-dawarich-app"
              "docker-dawarich-sidekiq"
            ]
            (_: {
              after = [ "init-dawarich-network.service" ];
              requires = [ "init-dawarich-network.service" ];
            });

        virtualisation.oci-containers = {
          backend = "docker";
          containers = {
            dawarich-db = {
              image = "postgis/postgis:17-3.5-alpine";
              environment = {
                POSTGRES_USER = "postgres";
                POSTGRES_DB = "dawarich_production";
              };
              environmentFiles = [ config.sops.secrets."dawarich/env".path ];
              volumes = [
                "dawarich-db:/var/lib/postgresql/data"
                "dawarich-shared:/var/shared"
              ];
              extraOptions = [
                "--network=dawarich"
                "--shm-size=1g"
              ];
            };

            dawarich-redis = {
              image = "redis:7.4-alpine";
              cmd = [
                "redis-server"
                "--save"
                "900"
                "1"
                "--save"
                "300"
                "10"
                "--appendonly"
                "no"
              ];
              volumes = [ "dawarich-shared:/data" ];
              extraOptions = [ "--network=dawarich" ];
            };

            dawarich-app = {
              image = "freikin/dawarich:latest";
              environment = {
                RAILS_ENV = "production";
                DATABASE_HOST = "dawarich-db";
                DATABASE_PORT = "5432";
                DATABASE_USERNAME = "postgres";
                DATABASE_NAME = "dawarich_production";
                REDIS_URL = "redis://dawarich-redis:6379";
                APPLICATION_HOSTS = "127.0.0.1,dawarich.buttars.lan,dawarich.buttars.dev";
                APPLICATION_PROTOCOL = "http";
                TIME_ZONE = "America/Denver";
                SELF_HOSTED = "true";
                STORE_GEODATA = "true";
                RAILS_LOG_TO_STDOUT = "true";
              };
              environmentFiles = [ config.sops.secrets."dawarich/env".path ];
              entrypoint = "web-entrypoint.sh";
              cmd = [
                "bin/rails"
                "server"
                "-p"
                "3000"
                "-b"
                "::"
              ];
              volumes = [
                "dawarich-public:/var/app/public"
                "dawarich-watched:/var/app/tmp/imports/watched"
                "dawarich-storage:/var/app/storage"
                "dawarich-db:/dawarich_db_data"
              ];
              ports = [ "127.0.0.1:3750:3000" ];
              extraOptions = [ "--network=dawarich" ];
              dependsOn = [
                "dawarich-db"
                "dawarich-redis"
              ];
            };

            dawarich-sidekiq = {
              image = "freikin/dawarich:latest";
              environment = {
                RAILS_ENV = "production";
                DATABASE_HOST = "dawarich-db";
                DATABASE_PORT = "5432";
                DATABASE_USERNAME = "postgres";
                DATABASE_NAME = "dawarich_production";
                REDIS_URL = "redis://dawarich-redis:6379";
                APPLICATION_HOSTS = "127.0.0.1,dawarich.buttars.lan,dawarich.buttars.dev";
                APPLICATION_PROTOCOL = "http";
                TIME_ZONE = "America/Denver";
                SELF_HOSTED = "true";
                STORE_GEODATA = "true";
                RAILS_LOG_TO_STDOUT = "true";
              };
              environmentFiles = [ config.sops.secrets."dawarich/env".path ];
              entrypoint = "sidekiq-entrypoint.sh";
              cmd = [ "sidekiq" ];
              volumes = [
                "dawarich-public:/var/app/public"
                "dawarich-watched:/var/app/tmp/imports/watched"
                "dawarich-storage:/var/app/storage"
              ];
              extraOptions = [ "--network=dawarich" ];
              dependsOn = [
                "dawarich-db"
                "dawarich-redis"
              ];
            };
          };
        };

        services.caddy.virtualHosts."http://dawarich.buttars.lan".extraConfig =
          "reverse_proxy http://127.0.0.1:3750";
      };
  };
}
