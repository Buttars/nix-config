{ config, lib, pkgs, ... }:
let
  cfg = config.host.modules.discord;
in
{
  options.host.modules.discord = {
    enable = lib.mkEnableOption "Enable Discord";
  };


  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      discord
      vesktop
      webcord
    ];
  };
}
