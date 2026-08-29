{ ... }:
{
  aegix.battery-notify.homeManager =
    { lib, pkgs, ... }:
    let
      # Descending. The script notifies once per bucket as the charge falls
      # through it, and resets when the battery starts charging again.
      thresholds = [
        20
        15
        10
        5
        3
      ];

      battery-notify = pkgs.writeShellApplication {
        name = "battery-notify";
        runtimeInputs = [
          pkgs.libnotify
          pkgs.coreutils
        ];
        text = ''
          bat=""
          for candidate in /sys/class/power_supply/BAT*; do
            if [ -r "$candidate/capacity" ]; then
              bat="$candidate"
              break
            fi
          done
          # Desktops have no battery; nothing to do.
          [ -n "$bat" ] || exit 0

          state="''${XDG_RUNTIME_DIR:-/tmp}/battery-notify.state"
          capacity=$(cat "$bat/capacity")
          status=$(cat "$bat/status")

          if [ "$status" != "Discharging" ]; then
            rm -f "$state"
            exit 0
          fi

          # Bucket = the lowest threshold the charge has already fallen through.
          bucket=""
          for t in ${lib.concatStringsSep " " (map toString thresholds)}; do
            if [ "$capacity" -le "$t" ]; then
              bucket="$t"
            fi
          done
          [ -n "$bucket" ] || exit 0

          last=$(cat "$state" 2>/dev/null || echo "")
          # Only fire on the way down, so a brief uptick cannot re-notify.
          if [ -n "$last" ] && [ "$bucket" -ge "$last" ]; then
            exit 0
          fi

          urgency=normal
          if [ "$bucket" -le 10 ]; then
            urgency=critical
          fi

          notify-send \
            --urgency="$urgency" \
            --icon=battery-caution \
            --hint=string:x-canonical-private-synchronous:battery \
            "Battery low: ''${capacity}%" \
            "Discharging - plug in soon."

          printf '%s' "$bucket" > "$state"
        '';
      };
    in
    lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      home.packages = [ battery-notify ];

      systemd.user.services.battery-notify = {
        Unit.Description = "Low battery notification";
        Service = {
          Type = "oneshot";
          ExecStart = "${battery-notify}/bin/battery-notify";
        };
      };

      systemd.user.timers.battery-notify = {
        Unit.Description = "Poll battery charge for low-battery notifications";
        Timer = {
          OnBootSec = "1m";
          OnUnitActiveSec = "1m";
        };
        Install.WantedBy = [ "timers.target" ];
      };
    };
}
