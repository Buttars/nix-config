{
  # The GTK4 file chooser: sidebar, search, recents, thumbnails. Pairs with
  # gvfs and tumbler from <aegix/desktop-services>, and matches the GNOME apps
  # already installed (nautilus, loupe, papers).
  aegix.portal-gnome.nixos =
    { pkgs, ... }:
    {
      xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gnome ];

      # Without explicit routing the backend is chosen by fallback order, which
      # is why dialogs behave inconsistently.
      xdg.portal.config.common = {
        default = [
          "hyprland"
          "gtk"
        ];
        "org.freedesktop.impl.portal.FileChooser" = [ "gnome" ];
      };
    };
}
