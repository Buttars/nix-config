{
  aegix.runtime-fetch.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.aegix.runtime-fetch;

      mkService = entry: {
        name = "fetch-${entry.name}";
        value = {
          Unit.Description = "Download ${entry.name}";
          Service = {
            Type = "oneshot";
            RemainAfterExit = true;
            Restart = "on-failure";
            RestartSec = 30;
            # Runs at runtime rather than as a fetchurl derivation so a
            # large emulation asset (game image, BIOS, HDD template, ...)
            # never blocks nixos-rebuild/home-manager switch — url/hash are
            # plain strings, not store paths, so nothing here forces a
            # build during activation.
            ExecStart = pkgs.writeShellScript "fetch-${entry.name}" ''
              set -euo pipefail
              dest=${lib.escapeShellArg entry.dest}
              if [ -e "$dest" ]; then
                exit 0
              fi
              mkdir -p "$(dirname "$dest")"
              tmp="$(mktemp)"
              trap 'rm -f "$tmp"' EXIT
              # --connect-timeout/--speed-* bound a broken or unreachable URL
              # to a couple minutes instead of hanging forever — this service
              # runs synchronously as part of default.target, so a stuck
              # fetch stalls the whole user session's activation queue,
              # which in turn can hang nixos-rebuild switch itself.
              ${lib.getExe pkgs.curl} -fL --retry 3 --connect-timeout 15 --speed-time 60 --speed-limit 1000 -o "$tmp" ${lib.escapeShellArg entry.url}
              echo "${entry.hash}  $tmp" | ${lib.getExe' pkgs.coreutils "sha256sum"} -c -
              ${entry.postFetch}
            '';
          };
          Install.WantedBy = [ "default.target" ];
        };
      };
    in
    {
      options.aegix.runtime-fetch.entries = lib.mkOption {
        type = lib.types.listOf (
          lib.types.submodule (
            { config, ... }:
            {
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
                  description = "Expected sha256 of the downloaded file, hex-encoded as printed by `sha256sum`.";
                };
                dest = lib.mkOption {
                  type = lib.types.str;
                  description = "Absolute path to place the final file at.";
                };
                xiso = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                  description = ''
                    Run `extract-xiso -D -r` on the fetched file after the hash check —
                    xemu needs discs rewritten into XISO format, plain ISOs won't boot.
                  '';
                };
                postFetch = lib.mkOption {
                  type = lib.types.str;
                  description = ''
                    Shell run after the download at $tmp passes its hash check, responsible
                    for producing $dest (e.g. moving it into place, or extracting an archive).
                  '';
                };
              };

              config.postFetch = lib.mkDefault (
                if config.xiso then
                  ''
                    mv "$tmp" "$dest"
                    ${lib.getExe' pkgs.extract-xiso "extract-xiso"} -D -r "$dest"
                  ''
                else
                  ''mv "$tmp" "$dest"''
              );
            }
          )
        );
        default = [ ];
        description = "Large emulation assets (game images, BIOS/HDD templates, ...) fetched at runtime instead of at build time.";
      };

      config.systemd.user.services = builtins.listToAttrs (map mkService cfg.entries);
    };
}
