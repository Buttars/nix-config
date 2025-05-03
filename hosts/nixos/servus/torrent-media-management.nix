{ ... }: {
  services.radarr = {
    enable = true;
    dataDir = "/srv/services/radarr";
  };

  services.lidarr = {
    enable = true;
    dataDir = "/srv/services/lidarr";
  };

  services.sonarr = {
    enable = true;
    dataDir = "/srv/services/sonarr";
  };

  services.prowlarr.enable = true;
}
