{ lib, ... }:
{
  # The aggregator side of telemetry: stores what every host exposes and draws
  # it. Kept host-agnostic so moving it off sentinel is a change of which host
  # includes it, not a rewrite.
  aegix.observability.nixos =
    { config, ... }:
    {
      options.aegix.observability.scrapeTargets = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [ "sentinel.lan:9100" ];
        description = "host:port pairs running node-exporter for prometheus to scrape.";
      };

      config = {
        sops.secrets.grafana-admin-password = {
          owner = "grafana";
        };

        # Encrypts datasource credentials in grafana's database. It has no
        # default upstream and cannot be rotated without re-encrypting, so it
        # wants setting once, before the first start.
        sops.secrets.grafana-secret-key = {
          owner = "grafana";
        };

        services.prometheus = {
          enable = true;
          port = 9090;
          listenAddress = "127.0.0.1";
          retentionTime = "90d";
          globalConfig.scrape_interval = "30s";
          scrapeConfigs = [
            {
              job_name = "nodes";
              static_configs = [
                { targets = config.aegix.observability.scrapeTargets; }
              ];
            }
          ];
        };

        services.grafana = {
          enable = true;
          settings = {
            server = {
              http_addr = "127.0.0.1";
              # 3000 is taken by zwave-js-server for home-assistant.
              http_port = 3001;
              root_url = "https://grafana.buttars.dev/";
            };
            # Read at runtime so the password never enters the nix store.
            security = {
              admin_password = "$__file{${config.sops.secrets.grafana-admin-password.path}}";
              secret_key = "$__file{${config.sops.secrets.grafana-secret-key.path}}";
            };
            analytics.reporting_enabled = false;
          };

          provision = {
            enable = true;
            datasources.settings.datasources = [
              {
                name = "Prometheus";
                type = "prometheus";
                access = "proxy";
                url = "http://127.0.0.1:9090";
                isDefault = true;
              }
            ];
          };
        };
      };
    };
}
