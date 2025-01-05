{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    arc-theme
    libsForQt5.qt5ct
    qt6ct
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    nwg-look
    papirus-icon-theme
    bibata-cursors
  ];

  environment.variables = {
    GTK_THEME = "Arc-Dark";
    QT_QPA_PLATFORMTHEME = "qt5ct";
    QT_STYLE_OVERRIDE = "gtk2";
    GDK_DPI_SCALE = "1";
    GTK_DPI_SCALE = "1";
    QT_FONT_DPI = "81";
    GDK_SCALE = "1";
    QT_SCALE_FACTOR = "1";
    XCURSOR_THEME = "Bibata-Modern-Ice";
    XCURSOR_SIZE = "20";
    GTK_ICON_THEME = "Papirus-Dark";
  };
}

