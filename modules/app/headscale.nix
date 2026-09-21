# Self-hosted coordination server for the tailscale client (replaces
# controlplane.tailscale.com). Binds loopback; sentinel's caddy is the only
# way in, same pattern as grafana and prometheus.
{ __findFile, ... }:
{
  aegix.headscale.nixos = {
    services.headscale = {
      enable = true;
      address = "127.0.0.1";
      port = 8090;
      settings = {
        server_url = "https://headscale.buttars.dev";
        dns = {
          magic_dns = true;
          # Must differ from server_url's domain; scopes MagicDNS names to
          # <host>.ts.buttars.dev without needing a public DNS delegation --
          # resolution happens inside the tailnet, not over public DNS.
          base_domain = "ts.buttars.dev";
          # Split DNS rather than a global override: only buttars.dev queries
          # go to sentinel's dnsmasq (so *.buttars.dev resolves to internal
          # addresses while connected, matching the split-horizon behavior
          # the wireguard setup relied on). Everything else keeps using the
          # client's own DNS, so a tunnel hiccup doesn't take down DNS for
          # the whole device the way a global override would.
          override_local_dns = false;
          nameservers.split."buttars.dev" = [ "10.0.40.6" ];
        };
      };
    };
  };
}
