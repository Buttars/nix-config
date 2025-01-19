{ pkgs, ... }: {
  programs.hyprland.enable = true;
  programs.xwayland.enable = true;

  environment.systemPackages = with pkgs; [
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
