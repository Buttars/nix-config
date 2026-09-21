{ __findFile, ... }:
{
  den.hosts.x86_64-linux.aegis = {
    users.aegis = {
      classes = [ "homeManager" ];
    };
  };
  den.aspects.aegis = {
    includes = [
      <den/define-user>
      <aegix/networking>
      <aegix/sops>
      <aegix/fail2ban>
      <aegix/tailscale>
    ];

    nixos =
      { config, pkgs, ... }:
      let
        # Proxying to sentinel's caddy rather than to a raw service port: one
        # allowed port between the segments instead of a router rule per
        # service, and it reaches services that bind loopback on sentinel.
        viaCaddy = host: ''
          tls {
            protocols tls1.2 tls1.3
          }
          reverse_proxy https://sentinel.lan {
            header_up Host {host}
            transport http {
              tls
              tls_server_name ${host}
            }
          }
        '';
      in
      {
        imports = [ ./_disko.nix ];

        aegix.vector.endpoint = "http://sentinel.lan:9428/insert/loki/api/v1/push";

        # aegis's own tailscale client would otherwise resolve
        # headscale.buttars.dev over public DNS to aegis's own WAN address and
        # hang trying to hairpin back through the router. This only affects
        # aegis's own outbound lookups; the public vhost below is untouched.
        #
        # Rather than hardcode sentinel's LAN address here, resolve the name
        # this file already trusts for the same purpose (sentinel.lan, used
        # by viaCaddy above) at boot, and seed /etc/hosts with the result
        # before tailscale tries to connect. mode = "0644" makes /etc/hosts a
        # real, boot-persistent file instead of a symlink into the nix store,
        # so the oneshot below is allowed to append to it.
        environment.etc.hosts.mode = "0644";

        systemd.services.headscale-hosts-override = {
          description = "Point headscale.buttars.dev at sentinel.lan for aegis's own tailscale join";
          wantedBy = [ "multi-user.target" ];
          before = [ "tailscaled-autoconnect.service" ];
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
          serviceConfig.Type = "oneshot";
          script = ''
            ip=$(${pkgs.dnsutils}/bin/dig +short sentinel.lan | head -n1)
            if [ -z "$ip" ]; then
              echo "could not resolve sentinel.lan; headscale.buttars.dev falls back to public DNS" >&2
              exit 1
            fi
            sed -i '/# headscale-lan-override$/d' /etc/hosts
            echo "$ip headscale.buttars.dev # headscale-lan-override" >> /etc/hosts
          '';
        };

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
          # headscale's ts2021 control protocol upgrades the connection like a
          # websocket, which has no equivalent in HTTP/2 -- caddy negotiates
          # h2 by default and rejects the upgrade before it ever reaches
          # sentinel, let alone headscale.
          globalConfig = ''
            servers {
              protocols h1
            }
          '';
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
              reverse_proxy http://theatrum.lan:8096 {
                header_up Host {host}
              }
            '';

            "requests.buttars.dev".extraConfig = ''
              tls {
                protocols tls1.2 tls1.3
              }
              reverse_proxy http://torrens.lan:5055 {
                header_up Host {host}
              }
            '';

            "home.buttars.dev".extraConfig = viaCaddy "home.buttars.dev";

            "dawarich.buttars.dev".extraConfig = ''
              tls {
                protocols tls1.2 tls1.3
              }
              reverse_proxy http://sentinel.lan:3750 {
                header_up Host {host}
              }
            '';

            "nextcloud.buttars.dev".extraConfig = ''
              tls {
                protocols tls1.2 tls1.3
              }
              reverse_proxy http://sentinel.lan:8080 {
                header_up Host {host}
              }
            '';

            "immich.buttars.dev".extraConfig = ''
              tls {
                protocols tls1.2 tls1.3
              }
              reverse_proxy http://sentinel.lan:2283 {
                header_up Host {host}
              }
            '';

            "ntfy.buttars.dev".extraConfig = viaCaddy "ntfy.buttars.dev";

            # Public entry point for the tailnet -- this is what replaces
            # reaching wireguard from off-LAN.
            "headscale.buttars.dev".extraConfig = viaCaddy "headscale.buttars.dev";
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
