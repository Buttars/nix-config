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

      fetchScript = entry: ''
        set -euo pipefail
        dest=${lib.escapeShellArg entry.dest}
        if [ -e "$dest" ]; then
          exit 0
        fi
        mkdir -p "$(dirname "$dest")"
        tmp="$(mktemp)"
        trap 'rm -f "$tmp"' EXIT
        # --connect-timeout/--speed-* bound a broken or unreachable URL to a
        # couple minutes instead of hanging forever.
        ${lib.getExe pkgs.curl} -fL --retry 3 --connect-timeout 15 --speed-time 60 --speed-limit 1000 -o "$tmp" ${lib.escapeShellArg entry.url}
        echo "${entry.hash}  $tmp" | ${lib.getExe' pkgs.coreutils "sha256sum"} -c -
        ${entry.postFetch}
      '';

      # No [Install] section and no Restart= here: this unit is only ever
      # triggered by its matching timer (mkTimer below), never enabled or
      # managed directly. Kept off default.target entirely — a unit
      # WantedBy=default.target gets swept into "restarting
      # sysinit-reactivation.target", which switch-to-configuration uses to
      # reconcile everything default.target wants after ANY system switch,
      # and that reconciliation waits for whatever's running under it to
      # settle. timers.target (used below) isn't part of that graph, so a
      # switch never has to wait on a download regardless of how long it
      # takes or how it's progressing.
      mkService = entry: {
        name = "fetch-${entry.name}";
        value = {
          Unit.Description = "Download ${entry.name}";
          Service = {
            Type = "oneshot";
            RemainAfterExit = true;
            # Runs at runtime rather than as a fetchurl derivation so a large
            # emulation asset (game image, BIOS, HDD template, ...) never
            # blocks nixos-rebuild/home-manager switch — url/hash are plain
            # strings, not store paths, so nothing here forces a build during
            # activation.
            ExecStart = pkgs.writeShellScript "fetch-${entry.name}" (fetchScript entry);
          };
        };
      };

      # Retries are timer-scheduled (OnUnitInactiveSec) rather than via
      # systemd's Restart=/RestartSec= service-restart limiter, which is what
      # made a stuck fetch (e.g. an unreachable placeholder URL) burn through
      # its 5 retries in under a minute and hit start-limit-hit previously.
      mkTimer = entry: {
        name = "fetch-${entry.name}";
        value = {
          Unit.Description = "Schedule download of ${entry.name}";
          Timer = {
            OnStartupSec = "30s";
            OnUnitInactiveSec = entry.retryInterval;
          };
          Install.WantedBy = [ "timers.target" ];
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
                  description = "Unit-name-safe slug (used as the systemd service/timer name).";
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
                retryInterval = lib.mkOption {
                  type = lib.types.str;
                  default = "10m";
                  description = "How long after a failed/incomplete attempt to retry (systemd time span, e.g. \"10m\").";
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
      config.systemd.user.timers = builtins.listToAttrs (map mkTimer cfg.entries);
    };
}
