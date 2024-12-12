{ config, pkgs, lib, ... }:
let
  cfg = config.host.profiles.hyprland;
in
{
  options.host.profiles.hyprland = {
    enable = lib.mkEnableOption "Enable hyprland compositor";
  };


  config = lib.mkIf cfg.enable {
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

  };
}
