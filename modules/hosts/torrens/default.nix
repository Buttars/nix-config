{
  __findFile,
  ...
}:
{
  den.hosts.x86_64-linux.torrens = {
    users.torrens = {
      classes = [ "homeManager" ];
      aspect = "torrens-user";
    };
  };
  den.aspects.torrens = {
    includes = [
      <den/define-user>
      <aegis/networking>
      <aegis/sops>
    ];

    nixos =
      { pkgs, config, ... }:
      {
        imports = [ ./_disko.nix ];

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

        sops.secrets.buttars-password.neededForUsers = true;
        sops.secrets.gluetun_env = { };

        users.mutableUsers = false;
        users.users.torrens.hashedPasswordFile = config.sops.secrets.buttars-password.path;
        users.users.torrens.extraGroups = [ "wheel" ];
        users.users.torrens.openssh.authorizedKeys.keyFiles = [
          ../../users/buttars/keys/id_ed25519.pub
        ];

        virtualisation.podman = {
          enable = true;
          defaultNetwork.settings.dns_enabled = true;
        };

        virtualisation.oci-containers = {
          backend = "podman";
          containers = {
            qbittorrent = {
              image = "lscr.io/linuxserver/qbittorrent:latest";
              environment = {
                PUID = "1000";
                PGID = "1000";
                TZ = "America/Denver";
                WEBUI_PORT = "8080";
              };
              volumes = [
                "/srv/services/qbittorrent/config:/config"
                "/srv/services/qbittorrent/downloads:/downloads"
                "/srv/media/movies:/movies"
                "/srv/media/shows:/shows"
              ];
              networks = [ "container:gluetun" ];
              dependsOn = [ "gluetun" ];
            };

            radarr = {
              image = "lscr.io/linuxserver/radarr:latest";
              environment = {
                PUID = "1000";
                PGID = "1000";
                TZ = "America/Denver";
              };
              volumes = [
                "/srv/services/radarr:/config"
                "/srv/media/movies:/movies"
                "/srv/services/qbittorrent/downloads:/downloads"
              ];
              networks = [ "container:gluetun" ];
              dependsOn = [ "gluetun" ];
            };

            sonarr = {
              image = "lscr.io/linuxserver/sonarr:latest";
              environment = {
                PUID = "1000";
                PGID = "1000";
                TZ = "America/Denver";
              };
              volumes = [
                "/srv/services/sonarr:/config"
                "/srv/media/shows:/shows"
                "/srv/services/qbittorrent/downloads:/downloads"
              ];
              networks = [ "container:gluetun" ];
              dependsOn = [ "gluetun" ];
            };

            lidarr = {
              image = "lscr.io/linuxserver/lidarr:latest";
              environment = {
                PUID = "1000";
                PGID = "1000";
                TZ = "America/Denver";
              };
              volumes = [
                "/srv/services/lidarr:/config"
                "/srv/media/music:/music"
                "/srv/services/qbittorrent/downloads:/downloads"
              ];
              networks = [ "container:gluetun" ];
              dependsOn = [ "gluetun" ];
            };

            prowlarr = {
              image = "lscr.io/linuxserver/prowlarr:latest";
              environment = {
                PUID = "1000";
                PGID = "1000";
                TZ = "America/Denver";
              };
              volumes = [ "/srv/services/prowlarr:/config" ];
              networks = [ "container:gluetun" ];
              dependsOn = [ "gluetun" ];
            };

            gluetun = {
              image = "qmcgaw/gluetun:latest";
              environmentFiles = [ config.sops.secrets.gluetun_env.path ];
              ports = [
                "8080:8080" # qBittorrent
                "7878:7878" # Radarr
                "8989:8989" # Sonarr
                "8686:8686" # Lidarr
                "9696:9696" # Prowlarr
              ];
              volumes = [ "/var/lib/gluetun:/gluetun" ];
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
