{
  # Alternative to <aegix/portal-gnome>: file dialogs open yazi in a floating
  # terminal instead of a GTK window. Swap which one capability/file-chooser
  # includes to switch. Not currently active.
  aegix.portal-termfilechooser.nixos =
    { pkgs, ... }:
    {
      xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-termfilechooser ];

      xdg.portal.config.common = {
        default = [
          "hyprland"
          "gtk"
        ];
        "org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
      };

      environment.etc."xdg/xdg-desktop-portal-termfilechooser/config".text = ''
        [filechooser]
        cmd=${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh
        default_dir=$HOME
        env=TERMCMD=kitty --class=termfilechooser
      '';
    };
}
