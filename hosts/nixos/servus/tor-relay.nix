{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nyx
  ];

  services.tor = {
    enable = true;
    openFirewall = true;
    relay = {
      enable = true;
      role = "relay";
    };
    settings = {
      ContactInfo = "toradmin.unrivaled112@passmail.net";
      Nickname = "Buttars";
      ORPort = 9001;
      ControlPort = 9051;
      BandWidthRate = "1 GBytes";
      HashedControlPassword = "16:D36722B1FEFD5498600A2A5837B7578F4FD840EA0715D8F4D6BC20D94E";
    };
  };
}
