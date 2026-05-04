{ __findFile, ... }:
{
  den.aspects.sentinel = {
    nixos = _: {
      services.gatus = {
        enable = true;
        settings = {
          web.port = 8888;
          endpoints = [
            {
              name = "Internal DNS (split-horizon)";
              group = "DNS";
              url = "10.0.40.6";
              dns = {
                query-name = "home.buttars.dev";
                query-type = "A";
              };
              interval = "5m";
              conditions = [
                "[DNS_RCODE] == NOERROR"
                "[BODY] == 10.0.40.6"
              ];
            }
            {
              name = "External DNS (public)";
              group = "DNS";
              url = "1.1.1.1";
              dns = {
                query-name = "home.buttars.dev";
                query-type = "A";
              };
              interval = "5m";
              conditions = [
                "[DNS_RCODE] == NOERROR"
                "[BODY] == 204.228.156.33"
              ];
            }
            {
              name = "Jellyfin";
              group = "Media";
              url = "https://jellyfin.buttars.dev";
              interval = "5m";
              conditions = [
                "[STATUS] == 200 || [STATUS] == 302"
              ];
            }
            {
              name = "Home Assistant";
              group = "Home";
              url = "https://home.buttars.dev";
              interval = "5m";
              conditions = [ "[STATUS] == 200" ];
            }
            {
              name = "Overseerr";
              group = "Media";
              url = "https://requests.buttars.dev";
              interval = "5m";
              conditions = [ "[STATUS] == 200" ];
            }
            {
              name = "Dawarich";
              group = "Home";
              url = "https://dawarich.buttars.dev";
              interval = "5m";
              conditions = [
                "[STATUS] == 200 || [STATUS] == 302"
              ];
            }
            {
              name = "qBittorrent";
              group = "Downloads";
              url = "https://qbittorrent.buttars.dev";
              interval = "5m";
              conditions = [
                "[STATUS] == 200 || [STATUS] == 302"
              ];
            }
            {
              name = "Radarr";
              group = "Downloads";
              url = "https://radarr.buttars.dev";
              interval = "5m";
              conditions = [ "[STATUS] == 200" ];
            }
            {
              name = "Sonarr";
              group = "Downloads";
              url = "https://sonarr.buttars.dev";
              interval = "5m";
              conditions = [ "[STATUS] == 200" ];
            }
            {
              name = "Lidarr";
              group = "Downloads";
              url = "https://lidarr.buttars.dev";
              interval = "5m";
              conditions = [ "[STATUS] == 200" ];
            }
            {
              name = "Bazarr";
              group = "Downloads";
              url = "https://bazarr.buttars.dev";
              interval = "5m";
              conditions = [ "[STATUS] == 200" ];
            }
            {
              name = "Prowlarr";
              group = "Downloads";
              url = "https://prowlarr.buttars.dev";
              interval = "5m";
              conditions = [ "[STATUS] == 200" ];
            }
          ];
        };
      };

    };
  };
}
