{ config, lib, pkgs, ... }: let
  cfg = config.hostConfig.modules.brave;
in {
  options.hostConfig.modules.brave = {
    enable = lib.mkEnableOption "Enable Brave Browser";
  };


  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      brave
    ];
  };
}
