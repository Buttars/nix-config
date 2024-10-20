{ config, lib, ... }:
let
  cfg = config.host.profiles.syncthing;
in
{
  options.host.profiles.syncthing = {
    enable = lib.mkEnableOption "Enable syncthing profile";
  };

  config = lib.mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      user = "buttars";
      dataDir = "/home/buttars/Documents";
      configDir = "/home/buttars/Documents/.config/syncthing";
    };
  };
}
