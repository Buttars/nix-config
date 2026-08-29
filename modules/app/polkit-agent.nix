{ ... }:
{
  # polkitd runs system-wide, but without an agent nothing renders the
  # authentication dialog, so GUI privilege requests fail silently.
  aegix.polkit-agent.homeManager =
    { lib, pkgs, ... }:
    lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      systemd.user.services.hyprpolkitagent = {
        Unit = {
          Description = "Polkit authentication agent";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.hyprpolkitagent}/bin/hyprpolkitagent";
          Restart = "on-failure";
          RestartSec = 2;
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    };
}
