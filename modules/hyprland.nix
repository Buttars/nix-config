{ config, pkgs, lib, ... }:
let
  cfg = config.host.modules.hyprland;
in
{
  options.host.modules.hyprland = {
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
    ];

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
      ];
    };
  };
}
