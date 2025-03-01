{ pkgs, ... }:
{
  home.packages = with pkgs; [
    libsForQt5.qt5ct
    qt6ct
    nwg-look
  ];

  qt.enable = true;
  qt.platformTheme.name = "gtk";
  qt.style.name = "adwaita-dark";

  gtk.enable = true;
  gtk.cursorTheme.package = pkgs.bibata-cursors;
  gtk.cursorTheme.name = "Bibata-Modern-Ice";

  gtk.theme.package = pkgs.arc-theme;
  gtk.theme.name = "Arc-Dark";

  gtk.iconTheme.package = pkgs.papirus-icon-theme;
  gtk.iconTheme.name = "Papirus-Dark";
}

