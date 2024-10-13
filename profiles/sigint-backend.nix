{ config, lib, pkgs, ... }:
let
  cfg = config.hostConfig.profiles.sigint-backend;
in
{
  options.hostConfig.profiles.sigint-backend = {
    enable = lib.mkEnableOption "Enable sigint-backend profile";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      dump1090
      rtl-ais
      rtl-sdr
    ];
  };

}
