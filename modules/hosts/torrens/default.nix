{
  __findFile,
  ...
}:
{
  den.hosts.x86_64-linux.torrens = { };
  den.aspects.torrens = {
    includes = [
      <den/define-user>
      <aegis/networking>
      <aegis/sops>
      (<aegis/disks/btrfs> {
        disk = "/dev/sda";
        withSwap = true;
        swapSize = "8";
      })
    ];

    nixos =
      { pkgs, config, ... }:
      {
        hardware.facter.reportPath = ./facter.json;
        hardware.facter.detected.dhcp.interfaces = [ "ens18" ];

        networking = {
          firewall = {
            enable = true;
            allowedTCPPorts = [
              22 # SSH
              8080 # qBittorrent WebUI
              7878 # Radarr
              8989 # Sonarr
              8686 # Lidarr
              9696 # Prowlarr
            ];
          };
        };

        services.openssh.enable = true;
        services.openssh.settings.PermitRootLogin = "yes";
        users.users.root.openssh.authorizedKeys.keyFiles = [
          ../../users/buttars/keys/id_ed25519.pub
        ];

        environment.systemPackages = [ pkgs.nfs-utils ];

        fileSystems."/srv" =
          let
            nfsProvider = "truenas.lan";
            nfsOptions = [
              "defaults"
              "noatime"
              "nfsvers=4.2"
              "rsize=262144"
              "wsize=262144"
              "nconnect=4"
              "async"
              "hard"
              "timeo=600"
              "retrans=2"
              "auto"
              "_netdev"
              "nofail"
            ];
          in
          {
            device = "${nfsProvider}:/mnt/veritas/cognito";
            fsType = "nfs";
            options = nfsOptions;
          };

        sops.secrets.gluetun_env = { };

        virtualisation.podman = {
          enable = true;
          defaultNetwork.settings.dns_enabled = true;
        };

        virtualisation.oci-containers = {
          backend = "podman";
          containers = {
            gluetun = {
              image = "qmcgaw/gluetun:latest";
              environment = {
                VPN_SERVICE_PROVIDER = "protonvpn";
                VPN_TYPE = "wireguard";
                SERVER_COUNTRIES = "Netherlands";
              };
              environmentFiles = [ config.sops.secrets.gluetun_env.path ];
              ports = [
                "8080:8080" # qBittorrent
                "7878:7878" # Radarr
                "8989:8989" # Sonarr
                "8686:8686" # Lidarr
                "9696:9696" # Prowlarr
              ];
              volumes = [ "/srv/services/gluetun:/gluetun" ];
              extraOptions = [
                "--cap-add=NET_ADMIN"
                "--device=/dev/net/tun:/dev/net/tun"
                "--sysctl=net.ipv6.conf.all.disable_ipv6=1"
              ];
            };
          };
        };
      };

    homeManager = { };
  };
}
