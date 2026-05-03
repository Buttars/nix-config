{ __findFile, ... }:
{
  den.aspects.sentinel = {
    nixos =
      {
        config,
        pkgs,
        lib,
        ...
      }:
      {
        sops.secrets.cloudflare_dns_zone_edit_api_token = { };

        sops.templates."caddy-cloudflare-env".content = ''
          CLOUDFLARE_API_TOKEN=${config.sops.placeholder.cloudflare_dns_zone_edit_api_token}
        '';

        services.caddy.email = "admin@buttars.dev";

        services.caddy.package = pkgs.caddy.withPlugins {
          plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
          hash = "sha256-Olz4W84Kiyldy+JtbIicVCL7dAYl4zq+2rxEOUTObxA=";
        };

        services.caddy.globalConfig = ''
          acme_dns cloudflare {env.CLOUDFLARE_API_TOKEN}
        '';

        systemd.services.caddy.serviceConfig.EnvironmentFile =
          config.sops.templates."caddy-cloudflare-env".path;

        services.caddy.virtualHosts = {
          "jellyfin.buttars.dev".extraConfig = "reverse_proxy http://theatrum.lan:8096";
          "requests.buttars.dev".extraConfig = "reverse_proxy http://torrens.lan:5055";
          "home.buttars.dev".extraConfig = "reverse_proxy http://127.0.0.1:8123";
          "dawarich.buttars.dev".extraConfig = "reverse_proxy http://127.0.0.1:3750";
        };
      };
  };
}
