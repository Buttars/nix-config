{ config, lib, pkgs, ... }:
let
  cfg = config.hostConfig.profiles.sigint;
in
{
  options.hostConfig.profiles.sigint = {
    enable = lib.mkEnableOption "Enable sigint profile";
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      dump1090
      rtl-ais
      rtl-sdr
      gqrx
      sdrpp
      multimon-ng
    ];


    hardware.rtl-sdr.enable = true;
  };

}


