{
  __findFile,
  lib,
  ...
}:
{
  # The aggregator side of telemetry: stores what every host exposes and draws
  # it. Kept host-agnostic so moving it off sentinel is a change of which host
  # includes it, not a rewrite.
  aegix.observability.includes = [ <aegix/ntfy> ];

  aegix.observability.nixos =
    { config, pkgs, ... }:
    let
      mkAlert =
        {
          uid,
          title,
          expr,
          duration,
          severity,
          summary,
          description,
        }:
        {
          inherit uid title;
          condition = "B";
          for = duration;
          # No matching series means nothing is wrong for every rule here, so
          # absence must not itself alert.
          noDataState = "OK";
          execErrState = "Error";
          labels.severity = severity;
          annotations = { inherit summary description; };
          data = [
            {
              refId = "A";
              relativeTimeRange = {
                from = 600;
                to = 0;
              };
              datasourceUid = "prometheus";
              model = {
                refId = "A";
                inherit expr;
                instant = true;
              };
            }
            {
              refId = "B";
              datasourceUid = "__expr__";
              model = {
                refId = "B";
                type = "threshold";
                expression = "A";
                conditions = [
                  {
                    evaluator = {
                      type = "gt";
                      params = [ 0 ];
                    };
                  }
                ];
              };
            }
          ];
        };
    in
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

        services.victorialogs = {
          enable = true;
          # Reachable from the fleet so other hosts can push. No auth, same
          # trust assumption as node-exporter: the LAN is trusted.
          listenAddress = ":9428";
          extraOptions = [ "-retentionPeriod=30d" ];
        };

        networking.firewall.allowedTCPPorts = [ 9428 ];

        # Grafana unified alerting rather than alertmanager: alertmanager 0.33.1
        # neither builds in this nixpkgs pin nor is cached, and grafana is
        # already here with the datasource wired up.
        services.grafana-to-ntfy = {
          enable = true;
          settings = {
            ntfyUrl = "http://127.0.0.1:2586/fleet";
            ntfyBAuthUser = config.aegix.ntfy.username;
            ntfyBAuthPass = config.sops.secrets."ntfy/password".path;
            # 8080 is nextcloud.
            port = 8099;
            markdown = true;
          };
        };

        services.grafana = {
          enable = true;
          # VictoriaLogs speaks LogsQL, which core grafana does not know.
          declarativePlugins = [ pkgs.grafanaPlugins.victoriametrics-logs-datasource ];
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

            alerting = {
              contactPoints.settings = {
                apiVersion = 1;
                contactPoints = [
                  {
                    orgId = 1;
                    name = "ntfy";
                    receivers = [
                      {
                        uid = "ntfy-webhook";
                        type = "webhook";
                        settings.url = "http://127.0.0.1:8099/";
                      }
                    ];
                  }
                ];
              };

              policies.settings = {
                apiVersion = 1;
                policies = [
                  {
                    orgId = 1;
                    receiver = "ntfy";
                    group_by = [
                      "alertname"
                      "grafana_folder"
                    ];
                    group_wait = "30s";
                    group_interval = "5m";
                    # Re-notify twice a day: often enough not to forget, rare
                    # enough not to train the reflex of dismissing it.
                    repeat_interval = "12h";
                  }
                ];
              };

              rules.settings = {
                apiVersion = 1;
                groups = [
                  {
                    orgId = 1;
                    name = "aegix";
                    folder = "Alerts";
                    interval = "1m";
                    rules = [
                      (mkAlert {
                        uid = "aegix-host-down";
                        title = "HostDown";
                        expr = ''up{job="nodes"} == 0'';
                        duration = "5m";
                        severity = "critical";
                        summary = "{{ $labels.instance }} is down";
                        description = "Prometheus has not scraped it for five minutes.";
                      })
                      (mkAlert {
                        uid = "aegix-disk-filling";
                        title = "DiskFillingUp";
                        expr = ''max by (instance, device) (100 - (node_filesystem_avail_bytes{fstype!~"tmpfs|ramfs|nfs.*|autofs"} / node_filesystem_size_bytes{fstype!~"tmpfs|ramfs|nfs.*|autofs"} * 100)) > 85'';
                        duration = "30m";
                        severity = "warning";
                        summary = "{{ $labels.instance }} {{ $labels.device }} is over 85% full";
                        description = "A full disk on the hypervisor paused three VMs once already.";
                      })
                      (mkAlert {
                        uid = "aegix-unit-failed";
                        title = "SystemdUnitFailed";
                        expr = ''node_systemd_unit_state{state="failed",name!~"restic-.*"} == 1'';
                        duration = "10m";
                        severity = "warning";
                        summary = "{{ $labels.name }} failed on {{ $labels.instance }}";
                        description = "The unit has been in the failed state for ten minutes.";
                      })
                      (mkAlert {
                        uid = "aegix-backup-failed";
                        title = "BackupFailed";
                        expr = ''node_systemd_unit_state{state="failed",name=~"restic-.*"} == 1'';
                        duration = "5m";
                        severity = "critical";
                        summary = "Backup job {{ $labels.name }} failed";
                        description = "Restic jobs failed silently for days before anyone noticed.";
                      })
                      (mkAlert {
                        uid = "aegix-fs-unreachable";
                        title = "FilesystemUnreachable";
                        expr = ''node_filesystem_device_error{fstype!~"tmpfs|ramfs"} == 1'';
                        duration = "10m";
                        severity = "critical";
                        summary = "{{ $labels.instance }} cannot stat {{ $labels.mountpoint }} ({{ $labels.fstype }})";
                        description = "Usually a stale NFS mount after truenas restarted.";
                      })
                    ];
                  }
                ];
              };
            };

            # Dashboards are files in this repo, not state clicked into
            # grafana's database, so a rebuilt host comes back with them.
            dashboards.settings.providers = [
              {
                name = "aegix";
                options.path = ./observability;
                # The files are read-only in the store; let grafana say so
                # rather than let someone edit a dashboard that will silently
                # revert on the next deploy.
                allowUiUpdates = false;
                disableDeletion = true;
              }
            ];

            # Adding a uid to a datasource that grafana already stores fails
            # provisioning with "data source not found"; deleting by name first
            # lets it be recreated with the uid the alert rules reference.
            datasources.settings.deleteDatasources = [
              {
                name = "Prometheus";
                orgId = 1;
              }
            ];

            datasources.settings.datasources = [
              {
                name = "Prometheus";
                uid = "prometheus";
                type = "prometheus";
                access = "proxy";
                url = "http://127.0.0.1:9090";
                isDefault = true;
              }
              {
                name = "VictoriaLogs";
                type = "victoriametrics-logs-datasource";
                access = "proxy";
                url = "http://127.0.0.1:9428";
              }
            ];
          };
        };
      };
    };
}
