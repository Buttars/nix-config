{ pkgs, ... }: {

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
      BandWidthRate = "1 MBytes";
    };
  };
}
