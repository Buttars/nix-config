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
      <aegix/networking>
      <aegix/sops>
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
              5055 # Jellyseerr
              8080 # qBittorrent WebUI
              7878 # Radarr
              8989 # Sonarr
              8686 # Lidarr
              9696 # Prowlarr
            ];
          };
          # Host-level kill switch: block container traffic from bypassing VPN.
          # Allows LAN and WireGuard (UDP 51820) only; drops everything else.
          # Runs before the firewall's trusted-interface rules (priority filter - 10).
          nftables.tables.podman-kill-switch = {
            family = "inet";
            content = ''
              chain forward {
                type filter hook forward priority filter - 10; policy accept;
                iifname "podman0" ip daddr { 10.0.0.0/8, 192.168.0.0/16 } accept
                iifname "podman0" udp dport 51820 accept
                iifname "podman0" drop
              }
            '';
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

        systemd.tmpfiles.rules = [
          "d /var/lib/qbittorrent 0755 root root -"
        ];

        systemd.services = {
          podman-qbittorrent = {
            after = [ "srv.mount" ];
            wants = [ "srv.mount" ];
          };
          podman-gluetun = {
            after = [ "srv.mount" ];
            wants = [ "srv.mount" ];
          };
          radarr = {
            after = [ "srv.mount" ];
            wants = [ "srv.mount" ];
          };
          sonarr = {
            after = [ "srv.mount" ];
            wants = [ "srv.mount" ];
          };
          lidarr = {
            after = [ "srv.mount" ];
            wants = [ "srv.mount" ];
          };
          prowlarr = {
            after = [ "srv.mount" ];
            wants = [ "srv.mount" ];
          };
        };

        services.seerr.enable = true;

        services.radarr = {
          enable = true;
          dataDir = "/var/lib/radarr";
        };
        services.sonarr = {
          enable = true;
          dataDir = "/var/lib/sonarr";
        };
        services.lidarr = {
          enable = true;
          dataDir = "/var/lib/lidarr";
        };
        services.prowlarr.enable = true;

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
                "/var/lib/qbittorrent:/config"
                "/srv/services/qbittorrent/downloads:/downloads"
                "/srv/media/movies:/movies"
                "/srv/media/shows:/shows"
                "/srv/media/music:/music"
              ];
              networks = [ "container:gluetun" ];
              dependsOn = [ "gluetun" ];
            };

            byparr = {
              image = "ghcr.io/thephaseless/byparr:latest";
              ports = [ "127.0.0.1:8191:8191" ];
            };

            gluetun = {
              image = "qmcgaw/gluetun:latest";
              environmentFiles = [ config.sops.secrets.gluetun_env.path ];
              environment = {
                FIREWALL_OUTBOUND_SUBNETS = "10.0.40.0/24";
                DOT = "off";
                DNS_ADDRESS = "10.0.40.1";
              };
              ports = [
                "8080:8080" # qBittorrent
              ];
              extraOptions = [
                "--cap-add=NET_ADMIN"
                "--cap-add=NET_RAW"
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
