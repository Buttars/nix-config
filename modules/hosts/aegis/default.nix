{ __findFile, ... }:
{
  den.hosts.x86_64-linux.aegis = {
    users.aegis = {
      classes = [ "homeManager" ];
      aspect = "aegis-user";
    };
  };
  den.aspects.aegis = {
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
        users.users.aegis.hashedPasswordFile = config.sops.secrets.buttars-password.path;
        users.users.aegis.extraGroups = [ "wheel" ];
        users.users.aegis.createHome = true;
        systemd.tmpfiles.rules = [
          "d /home/aegis/.ssh 0700 aegis users -"
        ];
        sops.secrets."private_keys/aegis" = {
          owner = "aegis";
          path = "/home/aegis/.ssh/id_ed25519";
          mode = "0600";
        };
        users.users.aegis.openssh.authorizedKeys.keyFiles = [ ../../users/buttars/keys/id_ed25519.pub ];

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

            "http://bazarr.buttars.lan".extraConfig = "reverse_proxy http://torrens.lan:6767";
            "bazarr.buttars.dev".extraConfig = ''
              tls {
                protocols tls1.2 tls1.3
              }
              reverse_proxy http://torrens.lan:6767
            '';

            "http://prowlarr.buttars.lan".extraConfig = "reverse_proxy http://torrens.lan:9696";
            "prowlarr.buttars.dev".extraConfig = ''
              tls {
                protocols tls1.2 tls1.3
              }
              reverse_proxy http://torrens.lan:9696
            '';

            "http://home.buttars.lan".extraConfig = "reverse_proxy http://sentinel.lan:8123";
            "home.buttars.dev".extraConfig = ''
              tls {
                protocols tls1.2 tls1.3
              }
              reverse_proxy http://sentinel.lan:8123
            '';
          };
        };

        networking.firewall.allowedTCPPorts = [
          80
          443
        ];

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
