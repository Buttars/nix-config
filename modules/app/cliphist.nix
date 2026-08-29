{ ... }:
{
  aegix.cliphist.homeManager =
    { lib, pkgs, ... }:
    lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      services.cliphist = {
        enable = true;
        allowImages = true;
      };
      # Without this, copied text dies with the window that owned it.
      systemd.user.services.wl-clip-persist = {
        Unit = {
          Description = "Preserve clipboard contents after the source window closes";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.wl-clip-persist}/bin/wl-clip-persist --clipboard regular";
          Restart = "on-failure";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    };
}
