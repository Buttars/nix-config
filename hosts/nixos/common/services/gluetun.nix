{ lib, config, pkgs, ... }:
let
  cfg = config.gluetun;
in
{
  options.gluetun = {
    enable = lib.mkEnableOption "Enable the Gluetun VPN container.";

    containerName = lib.mkOption {
      type = lib.types.str;
      default = "gluetun";
      description = "Container name (should match qbittorrent.gluetun.containerName if shared).";
    };

    envFile = lib.mkOption {
      type = lib.types.path;
      default = "/run/secrets/gluetun.env";
      description = "Decrypted .env file containing VPN credentials.";
    };

    ports = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "8080:8080/tcp" "6881:6881/udp" "61474:61474/tcp" ];
      description = "List of ports to expose from the Gluetun container.";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers.gluetun = {
      image = "qmcgaw/gluetun:latest";

      environmentFiles = [
        "/run/secrets/gluetun_env"
      ];

      ports = cfg.ports;

      volumes = [
        # You could include a mount like this if needed:
        "/run/gluetun:/gluetun"
      ];

      extraOptions = [
        "--cap-add=NET_ADMIN"
        "--device=/dev/net/tun"
        "--sysctl"
        "net.ipv6.conf.all.disable_ipv6=0"
      ];
    };
  };
}
