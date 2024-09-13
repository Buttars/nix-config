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
      grim
      slurp
      wl-clipboard
      rofi-wayland
      waybar
      font-awesome
      hyprpaper
      xwaylandvideobridge
      jq
      dunst
      wlogout
      hyprlock
    ];

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
      ];
    };
  };
}
