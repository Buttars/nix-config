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
      stateDir = "/var/lib/attic";
    in
    {
      options.aegix.attic = {
        url = lib.mkOption {
          type = lib.types.str;
          default = "http://sentinel.lan:8081/${cache}";
          description = "Substituter URL for the LAN cache.";
        };

        publicKey = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = "lan:RrWahHjgqVXHnSL62BqErnbuBAzUK+IxOpKWMHCQZUQ=";
          description = "Signing key from `attic cache info ${cache}`. Null leaves the substituter unconfigured.";
        };

        push = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Upload what this host builds. Requires the client token from sops.";
        };
      };

      config = lib.mkMerge [
        {
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
          systemd.tmpfiles.rules = [
            "d ${stateDir} 0700 root root -"
            "d ${stateDir}/attic 0700 root root -"
          ];

          nix.settings.post-build-hook = pkgs.writeShellScript "attic-push" ''
            export XDG_CONFIG_HOME=${stateDir}
            exec ${lib.getExe pkgs.attic-client} push ${cache} $OUT_PATHS
          '';
        })

        (lib.optionalAttrs (options ? sops) (
          lib.mkIf cfg.push {
            sops.secrets.attic-client-config.path = "${stateDir}/attic/config.toml";
          }
        ))
      ];
    };
}
