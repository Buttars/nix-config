{ __findFile, ... }:
{
  den.aspects.sentinel = {
    nixos =
      {
        config,
        pkgs,
        ...
      }:
      {
        sops.secrets."cloudflare/env" = { };

        services.caddy.email = "admin@buttars.dev";

        services.caddy.package = pkgs.caddy.withPlugins {
          plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
          hash = "sha256-bzMqxWTqrJ1skZmRTXyEMCKStXpljbqe5r0Ve2cnBfM=";
        };

        services.caddy.globalConfig = ''
          acme_dns cloudflare {env.CLOUDFLARE_API_TOKEN}
        '';

        systemd.services.caddy.serviceConfig.EnvironmentFile = config.sops.secrets."cloudflare/env".path;

        services.caddy.virtualHosts =
          let
            proxy = upstream: ''
              reverse_proxy ${upstream} {
                header_up Host {host}
                header_up X-Forwarded-For {remote_host}
                header_up X-Forwarded-Proto {scheme}
              }
            '';
            jellyfinProxy = upstream: ''
              reverse_proxy ${upstream} {
                header_up Host {host}
                header_up X-Forwarded-For {remote_host}
                header_up X-Forwarded-Proto {scheme}
                header_up X-Emby-Authorization {http.request.header.X-Emby-Authorization}
              }
            '';
          in
          {
            "jellyfin.buttars.dev".extraConfig = jellyfinProxy "http://theatrum.lan:8096";
            "requests.buttars.dev".extraConfig = proxy "http://torrens.lan:5055";
            "home.buttars.dev".extraConfig = proxy "http://127.0.0.1:8123";
            "dawarich.buttars.dev".extraConfig = proxy "http://127.0.0.1:3750";
            "qbittorrent.buttars.dev".extraConfig = proxy "http://torrens.lan:8080";
            "radarr.buttars.dev".extraConfig = proxy "http://torrens.lan:7878";
            "sonarr.buttars.dev".extraConfig = proxy "http://torrens.lan:8989";
            "lidarr.buttars.dev".extraConfig = proxy "http://torrens.lan:8686";
            "bazarr.buttars.dev".extraConfig = proxy "http://torrens.lan:6767";
            "prowlarr.buttars.dev".extraConfig = proxy "http://torrens.lan:9696";
            "gatus.buttars.dev".extraConfig = proxy "http://127.0.0.1:8888";
            "nextcloud.buttars.dev".extraConfig = proxy "http://127.0.0.1:8080";
            "immich.buttars.dev".extraConfig = proxy "http://127.0.0.1:2283";
          };
      };
  };
}
