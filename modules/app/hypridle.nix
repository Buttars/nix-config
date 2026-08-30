{ ... }:
{
  aegix.hypridle.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.aegix.hypridle;

      # buttars-laptop has a resume device and offset; buttars-desktop does
      # not, and suspend-then-hibernate fails outright where hibernation is
      # unavailable. Ask systemd at runtime rather than assuming per host.
      idle-sleep = pkgs.writeShellApplication {
        name = "idle-sleep";
        runtimeInputs = [ pkgs.systemd ];
        text = ''
          if systemctl suspend-then-hibernate --dry-run >/dev/null 2>&1; then
            systemctl suspend-then-hibernate
          else
            systemctl suspend
          fi
        '';
      };
    in
    {
      options.aegix.hypridle.autoSleep = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Suspend after a long idle. Blanking and locking still apply when disabled.";
      };

      config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        home.packages = lib.optional cfg.autoSleep idle-sleep;

        services.hypridle = {
          enable = true;
          settings = {
            general = {
              lock_cmd = "pidof hyprlock || hyprlock";
              before_sleep_cmd = "loginctl lock-session";
              after_sleep_cmd = "hyprctl dispatch dpms on";
            };

            listener = [
              {
                timeout = 300;
                on-timeout = "hyprctl dispatch dpms off";
                on-resume = "hyprctl dispatch dpms on";
              }
              {
                timeout = 600;
                on-timeout = "loginctl lock-session";
              }
            ]
            ++ lib.optional cfg.autoSleep {
              # Suspends now; systemd hibernates from there after
              # HibernateDelaySec, so a long absence ends powered off.
              timeout = 1800;
              on-timeout = "${idle-sleep}/bin/idle-sleep";
            };
          };
        };
      };
    };
}
