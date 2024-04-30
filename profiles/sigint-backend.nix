{ config, pkgs, ... }: {
  imports = [];

  environment.systemPackages = with pkgs; [
    dump1090
    rtl-ais
    rtl-sdr
  ];

}
