{ config, lib, pkgs, ... }: let
  cfg = config.hostConfig.modules.steam;
in {
  options.hostConfig.modules.steam = {
    enable = lib.mkEnableOption "Enable Steam";
  };


  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ ];

    programs.steam.enable = true;
  };
}
