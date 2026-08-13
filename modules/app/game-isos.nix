{
  aegix.game-isos.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.aegix.game-isos;

      mkService = entry: {
        name = "fetch-iso-${entry.name}";
        value = {
          Unit.Description = "Download ${entry.name} ISO";
          Service = {
            Type = "oneshot";
            RemainAfterExit = true;
            Restart = "on-failure";
            RestartSec = 30;
            # Runs at runtime rather than as a fetchurl derivation so a
            # multi-GB game image never blocks nixos-rebuild/home-manager
            # switch — url/hash are plain strings, not store paths, so
            # nothing here forces a build during activation.
            ExecStart = pkgs.writeShellScript "fetch-iso-${entry.name}" ''
              set -euo pipefail
              dest=${lib.escapeShellArg entry.dest}
              if [ -e "$dest" ]; then
                exit 0
              fi
              mkdir -p "$(dirname "$dest")"
              tmp="$dest.part"
              ${lib.getExe pkgs.curl} -fL --retry 3 -o "$tmp" ${lib.escapeShellArg entry.url}
              echo "${entry.hash}  $tmp" | ${lib.getExe' pkgs.coreutils "sha256sum"} -c -
              mv "$tmp" "$dest"
            '';
          };
          Install.WantedBy = [ "default.target" ];
        };
      };
    in
    {
      options.aegix.game-isos.entries = lib.mkOption {
        type = lib.types.listOf (
          lib.types.submodule {
            options = {
              name = lib.mkOption {
                type = lib.types.str;
                description = "Unit-name-safe slug (used as the systemd service name).";
              };
              url = lib.mkOption {
                type = lib.types.str;
                description = "Source URL. Must be somewhere you have the legal right to download from.";
              };
              hash = lib.mkOption {
                type = lib.types.str;
                description = "Expected sha256, hex-encoded as printed by `sha256sum`.";
              };
              dest = lib.mkOption {
                type = lib.types.str;
                description = "Absolute path to place the verified file at.";
              };
            };
          }
        );
        default = [ ];
        description = "Large game images fetched at runtime (after login, outside the Nix store) instead of at build time.";
      };

      config.systemd.user.services = builtins.listToAttrs (map mkService cfg.entries);
    };
}
