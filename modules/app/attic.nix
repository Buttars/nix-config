{
  aegix.attic.nixos =
    {
      config,
      options,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.aegix.attic;
      cache = "lan";
      stateDir = "/var/lib/attic-watch-store";
    in
    {
      options.aegix.attic = {
        url = lib.mkOption {
          type = lib.types.str;
          default = "http://sentinel.lan:8081/${cache}";
        };

        publicKey = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = ''
            The cache's signing key, from `attic cache info ${cache}` once the
            cache exists. Null leaves the substituter unconfigured: nix refuses
            paths it cannot verify, so pointing at the cache before the key is
            known would buy nothing and hide the misconfiguration.
          '';
        };

        push = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = ''
            Upload what this host builds. Off by default because it needs a
            client token from sops, which a host missing from .sops.yaml cannot
            decrypt.
          '';
        };
      };

      config = lib.mkMerge [
        {
          # buttars-laptop roams, so the cache is regularly unreachable. Cap the
          # wait and let nix carry on with the substituters it can reach.
          nix.settings.connect-timeout = 5;
          nix.settings.fallback = true;

          assertions = [
            {
              assertion = cfg.push -> options ? sops;
              message = "aegix.attic.push needs <aegix/sops>: the client token is a sops secret.";
            }
          ];
        }

        (lib.mkIf (cfg.publicKey != null) {
          nix.settings.substituters = [ cfg.url ];
          nix.settings.trusted-public-keys = [ cfg.publicKey ];
        })

        (lib.mkIf cfg.push {
          users.users.attic-watch-store = {
            isSystemUser = true;
            group = "attic-watch-store";
          };
          users.groups.attic-watch-store = { };

          # sops places the client config by symlink, so its parent has to
          # exist before sops-install-secrets runs.
          systemd.tmpfiles.rules = [
            "d ${stateDir} 0750 attic-watch-store attic-watch-store -"
            "d ${stateDir}/attic 0750 attic-watch-store attic-watch-store -"
          ];

          systemd.services.attic-watch-store = {
            description = "Upload locally built store paths to the ${cache} cache";
            wantedBy = [ "multi-user.target" ];
            # atticd only exists on sentinel, which pushes to itself; ordering
            # against a unit that is absent is a no-op everywhere else. Without
            # it the uploader races the server it is uploading to and the first
            # start after a deploy fails.
            after = [
              "network-online.target"
              "atticd.service"
            ];
            wants = [ "network-online.target" ];
            serviceConfig = {
              ExecStart = "${lib.getExe pkgs.attic-client} watch-store ${cache}";
              User = "attic-watch-store";
              Group = "attic-watch-store";
              Environment = [ "XDG_CONFIG_HOME=${stateDir}" ];
              Restart = "always";
              RestartSec = 60;
            };
          };
        })

        # vm and wgu-wsl carry no sops. mkIf alone would still leave the
        # definition attached to an option that was never declared there, so it
        # has to be absent rather than disabled.
        (lib.optionalAttrs (options ? sops) (
          lib.mkIf cfg.push {
            sops.secrets.attic-client-config = {
              owner = "attic-watch-store";
              path = "${stateDir}/attic/config.toml";
            };
          }
        ))
      ];
    };
}
