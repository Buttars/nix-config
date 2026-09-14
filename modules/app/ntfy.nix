{ lib, ... }:
{
  aegix.ntfy.nixos =
    { config, pkgs, ... }:
    let
      cfg = config.aegix.ntfy;
    in
    {
      options.aegix.ntfy = {
        baseUrl = lib.mkOption {
          type = lib.types.str;
          example = "https://ntfy.buttars.dev";
          description = "Public URL clients subscribe to and publishers post to.";
        };

        username = lib.mkOption {
          type = lib.types.str;
          default = "buttars";
          description = "Account seeded on first start, used to publish and subscribe.";
        };
      };

      config = {
        sops.secrets."ntfy/password" = { };

        services.ntfy-sh = {
          enable = true;
          settings = {
            base-url = cfg.baseUrl;
            listen-http = "127.0.0.1:2586";
            behind-proxy = true;
            # buttars.dev resolves publicly, so an open server would be a public
            # message board carrying host names and failure detail.
            auth-default-access = "deny-all";
          };
        };

        # ntfy has no declarative user database; it is a sqlite file the server
        # creates on first start. Seeding after the server is up means writing
        # into a file that already has the right ownership.
        systemd.services.ntfy-seed-user = {
          description = "Seed the ntfy account used for fleet alerts";
          wantedBy = [ "multi-user.target" ];
          after = [ "ntfy-sh.service" ];
          requires = [ "ntfy-sh.service" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          script = ''
            set -eu
            for _ in $(${pkgs.coreutils}/bin/seq 30); do
              [ -e /var/lib/ntfy-sh/user.db ] && break
              ${pkgs.coreutils}/bin/sleep 1
            done
            if ${pkgs.ntfy-sh}/bin/ntfy user list 2>/dev/null | ${pkgs.gnugrep}/bin/grep -q '${cfg.username}'; then
              exit 0
            fi
            NTFY_PASSWORD="$(${pkgs.coreutils}/bin/cat ${config.sops.secrets."ntfy/password".path})" \
              ${pkgs.ntfy-sh}/bin/ntfy user add --role=admin '${cfg.username}'
          '';
        };
      };
    };
}
