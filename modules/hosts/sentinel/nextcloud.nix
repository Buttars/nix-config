{ __findFile, ... }:
{
  den.aspects.sentinel = {
    nixos =
      { config, pkgs, ... }:
      {
        sops.secrets."nextcloud/admin-password" = {
          owner = "nextcloud";
        };

        services.nextcloud = {
          enable = true;
          package = pkgs.nextcloud33;
          hostName = "nextcloud.buttars.dev";
          https = true;
          datadir = "/var/lib/nextcloud";
          database.createLocally = true;
          config = {
            adminpassFile = config.sops.secrets."nextcloud/admin-password".path;
            dbtype = "pgsql";
          };
          settings = {
            trusted_proxies = [
              "127.0.0.1"
              "10.0.40.0/24"
            ];
            overwriteprotocol = "https";
          };
        };

        # nginx owns nextcloud's PHP-FPM; move it off port 80 so caddy can proxy to it
        services.nginx.defaultHTTPListenPort = 8080;

        users.users.nextcloud.uid = 994;
        users.groups.nextcloud.gid = 992;

        systemd.services."nextcloud-setup" = {
          after = [ "var-lib-nextcloud.mount" ];
          requires = [ "var-lib-nextcloud.mount" ];
        };

        environment.etc."fail2ban/filter.d/nextcloud.conf".text = ''
          [Definition]
          failregex = .*"remoteAddr":"<HOST>".*"message":"Login failed
          ignoreregex =
          datepattern = %%Y-%%m-%%dT%%H:%%M:%%S%%z
        '';

        services.fail2ban.jails.nextcloud.settings = {
          enabled = true;
          filter = "nextcloud";
          logpath = "/var/lib/nextcloud/data/nextcloud.log";
          maxretry = 5;
          findtime = "10m";
          bantime = "1h";
        };
      };
  };
}
