{ __findFile, ... }:
{
  den.hosts.x86_64-linux.sentinel = {
    users.sentinel = {
      classes = [ "homeManager" ];
      aspect = "sentinel-user";
    };
  };
  den.aspects.sentinel = {
    includes = [
      <den/define-user>
      <aegix/networking>
      <aegix/sops>
    ];

    nixos =
      { config, ... }:
      {
        imports = [ ./_disko.nix ];

        hardware.facter.reportPath = ./facter.json;
        hardware.facter.detected.dhcp.interfaces = [ "ens18" ];

        sops.secrets.buttars-password.neededForUsers = true;

        users.mutableUsers = false;
        users.users.sentinel.hashedPasswordFile = config.sops.secrets.buttars-password.path;
        users.users.sentinel.extraGroups = [ "wheel" ];
        users.users.sentinel.createHome = true;
        systemd.tmpfiles.rules = [
          "d /home/sentinel/.ssh 0700 sentinel users -"
        ];
        sops.secrets."private_keys/sentinel" = {
          owner = "sentinel";
          path = "/home/sentinel/.ssh/id_ed25519";
          mode = "0600";
        };
        users.users.sentinel.openssh.authorizedKeys.keyFiles = [ ../../users/buttars/keys/id_ed25519.pub ];

        services.openssh.enable = true;

        services.caddy = {
          enable = true;
          email = "admin@buttars.dev";
          virtualHosts = {
            "http://jellyfin.buttars.lan".extraConfig = "reverse_proxy http://theatrum.lan:8096";
            "jellyfin.buttars.dev".extraConfig = ''
              tls {
                protocols tls1.2 tls1.3
              }
              reverse_proxy http://theatrum.lan:8096
            '';

            "http://qbittorrent.buttars.lan".extraConfig = "reverse_proxy http://torrens.lan:8080";
            "qbittorrent.buttars.dev".extraConfig = ''
              tls {
                protocols tls1.2 tls1.3
              }
              reverse_proxy http://torrens.lan:8080
            '';

            "http://radarr.buttars.lan".extraConfig = "reverse_proxy http://torrens.lan:7878";
            "radarr.buttars.dev".extraConfig = ''
              tls {
                protocols tls1.2 tls1.3
              }
              reverse_proxy http://torrens.lan:7878
            '';

            "http://sonarr.buttars.lan".extraConfig = "reverse_proxy http://torrens.lan:8989";
            "sonarr.buttars.dev".extraConfig = ''
              tls {
                protocols tls1.2 tls1.3
              }
              reverse_proxy http://torrens.lan:8989
            '';

            "http://lidarr.buttars.lan".extraConfig = "reverse_proxy http://torrens.lan:8686";
            "lidarr.buttars.dev".extraConfig = ''
              tls {
                protocols tls1.2 tls1.3
              }
              reverse_proxy http://torrens.lan:8686
            '';

            "http://prowlarr.buttars.lan".extraConfig = "reverse_proxy http://torrens.lan:9696";
            "prowlarr.buttars.dev".extraConfig = ''
              tls {
                protocols tls1.2 tls1.3
              }
              reverse_proxy http://torrens.lan:9696
            '';
          };
        };

        services.dnsmasq = {
          enable = true;
          settings = {
            # Wildcard: all *.buttars.lan → sentinel (caddy handles routing)
            address = [
              "/.buttars.lan/10.0.40.9"
              "/sentinel.lan/10.0.40.9"
              "/torrens.lan/10.0.40.5"
              "/theatrum.lan/10.0.40.3"
            ];
            server = [
              "1.1.1.1"
              "8.8.8.8"
            ];
            cache-size = 1000;
            domain-needed = true;
            bogus-priv = true;
          };
        };

        networking.firewall.allowedTCPPorts = [
          53
          80
          443
        ];
        networking.firewall.allowedUDPPorts = [ 53 ];

        services.btrfs.autoScrub.enable = true;
        services.beesd.filesystems.nixroot = {
          spec = "/";
          hashTableSizeMB = 256;
          verbosity = "crit";
          extraOptions = [
            "--loadavg-target"
            "2.0"
          ];
        };
      };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.cowsay ];
      };
  };
}
