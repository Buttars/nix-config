{ config, lib, pkgs, ... }: let
  cfg = config.hostConfig.modules.discord;
in {
  options.hostConfig.modules.discord = {
    enable = lib.mkEnableOption "Enable Discord";
  };


  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      discord
      vesktop
    ];
  };
}
