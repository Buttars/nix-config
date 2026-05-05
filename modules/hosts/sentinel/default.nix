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
      { config, pkgs, ... }:
      {
        imports = [ ./_disko.nix ];

        hardware.facter.reportPath = ./facter.json;
        hardware.facter.detected.dhcp.interfaces = [ "ens18" ];

        sops.secrets.buttars-password.neededForUsers = true;

        users.mutableUsers = false;
        users.users.sentinel.hashedPasswordFile = config.sops.secrets.buttars-password.path;
        users.users.sentinel.extraGroups = [
          "wheel"
          "docker"
        ];
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

        environment.systemPackages = [ pkgs.nfs-utils ];

        fileSystems =
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
            serviceNfsOptions = [
              "defaults"
              "noatime"
              "nfsvers=3"
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
            serviceMount = name: {
              device = "${nfsProvider}:/mnt/veritas/services/${name}";
              fsType = "nfs";
              options = serviceNfsOptions;
            };
          in
          {
            "/srv" = {
              device = "${nfsProvider}:/mnt/veritas/cognito";
              fsType = "nfs";
              options = nfsOptions;
            };
            "/var/lib/hass" = serviceMount "home-assistant";
            "/var/lib/dawarich" = serviceMount "dawarich";
          };

        nix.settings.trusted-users = [ "sentinel" ];

        users.users.hass.uid = 286;
        users.groups.hass.gid = 286;

        services.openssh.enable = true;

        services.dnsmasq = {
          enable = true;
          settings = {
            address = [
              "/.buttars.dev/10.0.40.6"
            ];
            server = [
              "10.0.40.1"
              "1.1.1.1"
              "1.0.0.1"
            ];
            cache-size = 1000;
            domain-needed = true;
            bogus-priv = true;
          };
        };

        services.caddy.enable = true;

        networking.firewall.allowedTCPPorts = [
          53
          80
          443
          3750
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
