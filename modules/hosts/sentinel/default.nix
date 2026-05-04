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

        nix.settings.trusted-users = [ "sentinel" ];

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
