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
          # Point tailnet clients at sentinel's own dnsmasq so *.buttars.dev
          # and *.lan keep resolving to internal addresses while connected
          # remotely, matching the split-horizon behavior the wireguard setup
          # relied on.
          override_local_dns = true;
          nameservers.global = [ "10.0.40.6" ];
        };
      };
    };
  };
}
