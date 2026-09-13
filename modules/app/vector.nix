{ lib, ... }:
{
  aegix.vector.nixos =
    { config, ... }:
    let
      cfg = config.aegix.vector;
    in
    {
      options.aegix.vector = {
        endpoint = lib.mkOption {
          type = lib.types.str;
          default = "";
          example = "http://sentinel.lan:9428/insert/loki/api/v1/push";
          description = ''
            VictoriaLogs push endpoint. Empty disables shipping, which is the
            right setting for a host that roams off-network.
          '';
        };

        excludeUnits = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Systemd units whose logs are too noisy to ship.";
        };
      };

      config = lib.mkIf (cfg.endpoint != "") {
        services.vector = {
          enable = true;
          journaldAccess = true;
          settings = {
            sources.journal = {
              type = "journald";
              # Only what arrives from now on; back-filling every boot on first
              # start would ship months of history in one burst.
              current_boot_only = true;
              exclude_units = cfg.excludeUnits;
            };

            sinks.victorialogs = {
              type = "loki";
              inputs = [ "journal" ];
              endpoint = cfg.endpoint;
              encoding.codec = "json";
              # Vector cannot reach the aggregator while it is down or the host
              # is off-network; buffer to disk rather than dropping.
              buffer = {
                type = "disk";
                max_size = 268435488;
                when_full = "drop_newest";
              };
              labels = {
                host = "{{ host }}";
                unit = "{{ _SYSTEMD_UNIT }}";
              };
            };
          };
        };
      };
    };
}
