# NOT YET WIRED. This defines the aegix.janus aspect only -- there is no
# `den.hosts.x86_64-linux.janus` yet, so it builds nothing and nothing
# currently includes it. It exists so the config is ready to drop in once
# the VM is actually provisioned.
#
# Prerequisites before this can become a real host, modeled on
# modules/hosts/aegis/:
#   1. New VM on veritas, on the VPN VLAN (10.0.14.0/24 -- the segment the
#      wireguard setup this replaces already lives on).
#   2. Install NixOS, then `nixos-facter > modules/hosts/janus/facter.json`.
#   3. Enroll the host's age key and add `private_keys/janus` to
#      modules/app/sops/secrets.yaml (reuse buttars-password like every
#      other host does).
#   4. Add here:
#        den.hosts.x86_64-linux.janus.users.janus.classes = [ "homeManager" ];
#      plus `imports = [ ./_disko.nix ];` in the nixos block below, copied
#      from aegis's disko layout.
#   5. Add a `janus.lan` host-record to sentinel's dnsmasq once the VM's
#      address is known.
#   6. Router: allow 443 from aegis's DMZ segment to the VPN VLAN, the same
#      ACL entry aegis -> sentinel needed.
#
# Cutover from sentinel (do NOT delete sentinel's copy until this is
# verified working end to end):
#   - Copy sentinel's /var/lib/headscale/db.sqlite to janus first, or every
#     device re-registers from scratch (headscale's state is just that one
#     sqlite file -- there is nothing else to migrate).
#   - Repoint aegis's headscale.buttars.dev vhost at janus.lan instead of
#     sentinel.lan.
#   - Remove <aegix/headscale>, the subnet-router services.tailscale
#     override, and the headscale caddy vhost + h1 fix from
#     modules/hosts/sentinel/ (caddy.nix and default.nix).
#   - sentinel no longer needs <aegix/tailscale> at all once it's not the
#     subnet router -- it becomes reachable *through* janus's advertised
#     route rather than being a tailnet member with its own blast radius,
#     which is the whole point of this move.
{ __findFile, ... }:
{
  den.aspects.janus = {
    includes = [
      <den/define-user>
      <aegix/networking>
      <aegix/sops>
      <aegix/fail2ban>
      <aegix/headscale>
      <aegix/tailscale>
    ];

    nixos =
      { config, pkgs, ... }:
      {
        sops.secrets."cloudflare/env" = { };

        services.caddy = {
          enable = true;
          email = "admin@buttars.dev";
          package = pkgs.caddy.withPlugins {
            plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
            hash = "sha256-7GoH8YLCoPmPExQxoga2FHB58zQDoZVf1BBwkVi0SsQ=";
          };
          globalConfig = ''
            acme_dns cloudflare {env.CLOUDFLARE_API_TOKEN}

            # Same ts2021-vs-http2 issue sentinel and aegis both hit: caddy
            # negotiates h2 by default and rejects the control-protocol
            # upgrade before headscale ever sees it.
            servers {
              protocols h1
            }
          '';
          virtualHosts."headscale.buttars.dev".extraConfig = ''
            reverse_proxy 127.0.0.1:8090
          '';
        };

        systemd.services.caddy.serviceConfig.EnvironmentFile = config.sops.secrets."cloudflare/env".path;

        # janus is the fleet's one point of network-wide access. Moving the
        # subnet-router role here (off sentinel) is the actual point of this
        # host: sentinel and every other service host stay reachable through
        # janus's advertised route, without any of them needing tailnet
        # membership -- and therefore network-wide access -- of their own.
        services.tailscale = {
          useRoutingFeatures = "server";
          extraUpFlags = [ "--advertise-routes=10.0.0.0/16" ];
        };

        networking.firewall.allowedTCPPorts = [
          80
          443
        ];
      };
  };
}
