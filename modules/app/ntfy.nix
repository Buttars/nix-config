{ lib, ... }:
{
  aegix.ntfy.nixos =
    { config, pkgs, ... }:
    let
      cfg = config.aegix.ntfy;

      failureNotify = pkgs.writeShellScript "ntfy-failure" ''
        set -u
        unit="$1"
        # -u would put the password in the process list; a mode-600 curl
        # config file does not.
        conf=$(${pkgs.coreutils}/bin/mktemp)
        ${pkgs.coreutils}/bin/chmod 600 "$conf"
        ${pkgs.coreutils}/bin/printf 'user = "%s:%s"\n' \
          '${cfg.username}' \
          "$(${pkgs.coreutils}/bin/cat ${config.sops.secrets."ntfy/password".path})" > "$conf"
        ${pkgs.systemd}/bin/journalctl -u "$unit" -n 15 --no-pager 2>/dev/null \
          | ${pkgs.curl}/bin/curl -sS --max-time 20 -K "$conf" \
              -H "Title: $unit failed on $(${pkgs.nettools}/bin/hostname -s)" \
              -H "Priority: high" \
              -H "Tags: rotating_light" \
              --data-binary @- \
              http://127.0.0.1:2586/fleet || true
        ${pkgs.coreutils}/bin/rm -f "$conf"
      '';
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
            # Reachable from aegis, which is the public edge. Exposure is safe
            # because every topic requires auth.
            listen-http = ":2586";
            behind-proxy = true;
            # buttars.dev resolves publicly, so an open server would be a public
            # message board carrying host names and failure detail.
            auth-default-access = "deny-all";
          };
        };

        # Any unit can report its own death with
        #   onFailure = [ "ntfy-failure@%n.service" ];
        networking.firewall.allowedTCPPorts = [ 2586 ];

        systemd.services."ntfy-failure@" = {
          description = "Report a failed %i to ntfy";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${failureNotify} %i";
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
