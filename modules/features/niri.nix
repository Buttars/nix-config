{
  aegix.niri = {
    nixos = {
      programs.niri.enable = true;
      environment.pathsToLink = [
        "/share/applications"
        "/share/xdg-desktop-portal"
      ];
    };
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          fuzzel
          grim
          libnotify
          slurp
          swaynotificationcenter
          waybar
          wl-clipboard
          xdg-desktop-portal-gnome
        ];
      };
  };
}
