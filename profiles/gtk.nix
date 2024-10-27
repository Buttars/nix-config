{ config, lib, pkgs, ... }:
let
  cfg = config.host.profiles.gtk;
in
{
  options.host.profiles.gtk = {
    enable = lib.mkEnableOption "Enable gtk theming.";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      arc-theme
      libsForQt5.qt5ct
      qt6ct
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      papirus-icon-theme
      bibata-cursors
    ];

    environment.variables = {
      GTK_THEME = "Arc-Dark";
      QT_QPA_PLATFORMTHEME = "qt5ct";
      QT_STYLE_OVERRIDE = "gtk2";
      GDK_DPI_SCALE = "1.5";
      GTK_DPI_SCALE = "1.5";
      QT_FONT_DPI = "144";
      GDK_SCALE = "1.5";
      QT_SCALE_FACTOR = "1.5";
      XCURSOR_THEME = "Bibata-Modern-Ice";
      XCURSOR_SIZE = "20";
      GTK_ICON_THEME = "Papirus-Dark";
    };
  };
}

