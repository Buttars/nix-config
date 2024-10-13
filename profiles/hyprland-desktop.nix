{ config, pkgs, lib, ... }:
let
  cfg = config.hostConfig.profiles.hyprland;
in
{
  options.hostConfig.profiles.hyprland = {
    enable = lib.mkEnableOption "Enable hyprland compositor";
  };


  config = lib.mkIf cfg.enable {
    programs.hyprland.enable = true;
    programs.xwayland.enable = true;

    environment.systemPackages = with pkgs; [
      bibata-cursors
      dunst
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
    ];

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
      ];
    };
  };
}
