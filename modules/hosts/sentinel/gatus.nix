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
              url = "http://qbittorrent.buttars.lan";
              interval = "5m";
              conditions = [
                "[STATUS] == 200 || [STATUS] == 302"
              ];
            }
            {
              name = "Radarr";
              url = "http://radarr.buttars.lan";
              interval = "5m";
              conditions = [ "[STATUS] == 200" ];
            }
            {
              name = "Sonarr";
              url = "http://sonarr.buttars.lan";
              interval = "5m";
              conditions = [ "[STATUS] == 200" ];
            }
            {
              name = "Lidarr";
              url = "http://lidarr.buttars.lan";
              interval = "5m";
              conditions = [ "[STATUS] == 200" ];
            }
            {
              name = "Bazarr";
              url = "http://bazarr.buttars.lan";
              interval = "5m";
              conditions = [ "[STATUS] == 200" ];
            }
            {
              name = "Prowlarr";
              url = "http://prowlarr.buttars.lan";
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
