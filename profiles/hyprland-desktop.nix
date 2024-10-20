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
      swaynotificationcenter
      font-awesome
      glib
      grim
      hyprlock
      hyprpaper
      jq
      rofi-wayland
      slurp
      waybar
      waypaper
      wl-clipboard
      wlogout
      xwaylandvideobridge
      nautilus
    ];

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
      ];
    };
  };
}
