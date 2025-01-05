{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    dump1090
    rtl-ais
    rtl-sdr
    gqrx
    sdrpp
    multimon-ng
  ];

  hardware.rtl-sdr.enable = true;
}


