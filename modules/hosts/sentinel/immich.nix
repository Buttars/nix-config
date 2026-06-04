{ __findFile, ... }:
{
  den.aspects.sentinel = {
    nixos =
      { lib, pkgs, ... }:
      {
environment.systemPackages = [
          pkgs.immich-cli
          pkgs.immich
        ];

        services.immich = {
          enable = true;
          host = "0.0.0.0";
          mediaLocation = "/var/lib/immich";
        };

        systemd.services.immich-server = {
          after = [ "var-lib-immich.mount" ];
          requires = [ "var-lib-immich.mount" ];
          serviceConfig.StateDirectory = lib.mkForce "";
        };

        systemd.services.immich-machine-learning = {
          after = [ "var-lib-immich.mount" ];
          requires = [ "var-lib-immich.mount" ];
          serviceConfig.StateDirectory = lib.mkForce "";
        };

        environment.etc."fail2ban/filter.d/immich.conf".text = ''
          [Definition]
          failregex = Failed login attempt for user.* from <HOST>
          ignoreregex =
        '';

        services.fail2ban.jails.immich.settings = {
          enabled = true;
          filter = "immich";
          backend = "systemd";
          journalmatch = "_SYSTEMD_UNIT=immich-server.service";
          maxretry = 5;
          findtime = "10m";
          bantime = "1h";
        };
      };
  };
}
