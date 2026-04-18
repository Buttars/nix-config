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
      <aegix/fail2ban>
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

        fileSystems."/srv" =
          let
            nfsProvider = "truenas.lan";
            defaultNfsOptions = [
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
            options = defaultNfsOptions;
          };

        services.openssh.enable = true;

        systemd.services.home-assistant = {
          after = [ "srv.mount" ];
          requires = [ "srv.mount" ];
        };

        services.home-assistant = {
          enable = true;
          openFirewall = false;
          configDir = "/srv/services/home-assistant";
          config = {
            homeassistant = {
              name = "Home";
              unit_system = "us_customary";
              time_zone = "America/Denver";
            };
            http = {
              server_host = "0.0.0.0";
              use_x_forwarded_for = true;
              trusted_proxies = [
                "127.0.0.1"
                "10.0.40.0/24"
              ];
              ip_ban_enabled = true;
              login_attempts_threshold = 5;
            };
          };
        };

        services.dnsmasq = {
          enable = true;
          settings = {
            address = [ "/.buttars.lan/10.0.40.6" ];
            server = [
              "1.1.1.1"
              "1.0.0.1"
            ];
            cache-size = 1000;
            domain-needed = true;
            bogus-priv = true;
          };
        };

        services.caddy = {
          enable = true;
          virtualHosts = {
            "http://jellyfin.buttars.lan".extraConfig = "reverse_proxy http://theatrum.lan:8096";
            "http://qbittorrent.buttars.lan".extraConfig = "reverse_proxy http://torrens.lan:8080";
            "http://radarr.buttars.lan".extraConfig = "reverse_proxy http://torrens.lan:7878";
            "http://sonarr.buttars.lan".extraConfig = "reverse_proxy http://torrens.lan:8989";
            "http://lidarr.buttars.lan".extraConfig = "reverse_proxy http://torrens.lan:8686";
            "http://bazarr.buttars.lan".extraConfig = "reverse_proxy http://torrens.lan:6767";
            "http://prowlarr.buttars.lan".extraConfig = "reverse_proxy http://torrens.lan:9696";
            "http://home.buttars.lan".extraConfig = "reverse_proxy http://127.0.0.1:8123";
            "http://requests.buttars.lan".extraConfig = "reverse_proxy http://torrens.lan:5055";
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
