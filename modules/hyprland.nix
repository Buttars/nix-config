{ config, pkgs, lib, ... }: let
  cfg = config.hostConfig.modules.hyprland;
in {
  options.hostConfig.modules.hyprland = {
    enable = lib.mkEnableOption "Enable hyprland compositor";
  };


  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      #package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    };
  };
}
