{ hostname, config, ... }: {

  imports = [
    ./hardware-configuration.nix

    ../common/users/servus

    ./nfs-mounts.nix
    ./virtualisation.nix
    ./tor-relay.nix
    ./qbittorrent.nix
    ./gluetun-dynamic-port-forwarder.nix

    ../common/services/gluetun.nix
    ../common/services/home-assistant.nix
  ];


  sops.secrets."gluetun_env" = { };

  sops.secrets."gluetun_qbittorrent_env" = { };

  gluetun = {
    enable = true;
    containerName = "gluetun";
    envFile = "/run/secrets/gluetun_env";
    ports = [
      "8080:8080/tcp"
      "6881:6881/tcp"
      "6881:6881/udp"
    ];
  };

  qbittorrent = {
    enable = true;
    nfsAddress = "10.0.0.4";
    nfsExposedPath = "/mnt/veritas/cognito/services/qbittorrent";

    gluetun = {
      enable = true;
      qbittorrent-manager = {
        enable = true;
        envFile = "/run/secrets/gluetun_qbittorrent_env";
      };
    };
  };

  home-assistant = {
    enable = true;
    nfsAddress = "10.0.0.5";
    nfsExposedPath = "/mnt/veritas/cognito/services/home-assistant";
  };

  networking = {
    hostName = hostname;
    networkmanager.enable = true;
    firewall.enable = false;
    interfaces = {
      ens18 = {
        ipv4.addresses = [
          {
            address = "10.0.1.4";
            prefixLength = 16;
          }
        ];
      };
    };
    defaultGateway = "10.0.0.1";
    nameservers = [ "10.0.1.2" ];
  };

  services.openssh = {
    enable = true;
  };
}
