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
              name = "Jellyfin";
              url = "https://jellyfin.buttars.dev";
              interval = "5m";
              conditions = [
                "[STATUS] == 200 || [STATUS] == 302"
              ];
            }
            {
              name = "Home Assistant";
              url = "https://home.buttars.dev";
              interval = "5m";
              conditions = [ "[STATUS] == 200" ];
            }
            {
              name = "Overseerr";
              url = "https://requests.buttars.dev";
              interval = "5m";
              conditions = [ "[STATUS] == 200" ];
            }
            {
              name = "Dawarich";
              url = "https://dawarich.buttars.dev";
              interval = "5m";
              conditions = [
                "[STATUS] == 200 || [STATUS] == 302"
              ];
            }
            {
              name = "qBittorrent";
              url = "https://qbittorrent.buttars.dev";
              interval = "5m";
              conditions = [
                "[STATUS] == 200 || [STATUS] == 302"
              ];
            }
            {
              name = "Radarr";
              url = "https://radarr.buttars.dev";
              interval = "5m";
              conditions = [ "[STATUS] == 200" ];
            }
            {
              name = "Sonarr";
              url = "https://sonarr.buttars.dev";
              interval = "5m";
              conditions = [ "[STATUS] == 200" ];
            }
            {
              name = "Lidarr";
              url = "https://lidarr.buttars.dev";
              interval = "5m";
              conditions = [ "[STATUS] == 200" ];
            }
            {
              name = "Bazarr";
              url = "https://bazarr.buttars.dev";
              interval = "5m";
              conditions = [ "[STATUS] == 200" ];
            }
            {
              name = "Prowlarr";
              url = "https://prowlarr.buttars.dev";
              interval = "5m";
              conditions = [ "[STATUS] == 200" ];
            }
          ];
        };
      };

      services.caddy.virtualHosts."http://gatus.buttars.lan".extraConfig =
        "reverse_proxy http://127.0.0.1:8888";
    };
  };
}
