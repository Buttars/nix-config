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
          logFormat = ''
            output file /var/log/caddy/access.log {
              roll_size 100mb
              roll_keep 5
            }
            format json
          '';
          virtualHosts = {
            "jellyfin.buttars.dev".extraConfig = ''
              tls {
                protocols tls1.2 tls1.3
              }
              reverse_proxy http://jellyfin.buttars.lan
            '';

            "requests.buttars.dev".extraConfig = ''
              tls {
                protocols tls1.2 tls1.3
              }
              reverse_proxy http://requests.buttars.lan
            '';

            "home.buttars.dev".extraConfig = ''
              tls {
                protocols tls1.2 tls1.3
              }
              reverse_proxy http://home.buttars.lan
            '';

            "dawarich.buttars.dev".extraConfig = ''
              tls {
                protocols tls1.2 tls1.3
              }
              reverse_proxy http://dawarich.buttars.lan
            '';
          };
        };

        environment.etc."fail2ban/filter.d/caddy-4xx.conf".text = ''
          [Definition]
          failregex = .*"remote_ip":"<HOST>".*"status":40[1-9]
          ignoreregex =
        '';

        services.fail2ban.jails.caddy-4xx.settings = {
          enabled = true;
          filter = "caddy-4xx";
          logpath = "/var/log/caddy/access.log";
          maxretry = 10;
          findtime = "10m";
          bantime = "1h";
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
