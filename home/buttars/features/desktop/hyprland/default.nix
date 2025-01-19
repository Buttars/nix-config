{ pkgs, ... }: {
  # programs.hyprland.enable = true;
  # programs.xwayland.enable = true;

  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.xwayland.enable = true;


  home.packages = with pkgs; [
    bibata-cursors
    font-awesome
    glib
    grim
    hyprlock
    hyprpaper
    hyprpicker
    jq
    nautilus
    rofi-wayland
    slurp
    swaynotificationcenter
    waybar
    waypaper
    wl-clipboard
    wlogout
    xwaylandvideobridge
  ];
}
