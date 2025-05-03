{ ... }: {
  services.radarr = {
    enable = true;
  };

  services.lidarr = {
    enable = true;
  };

  services.sonarr = {
    enable = true;
  };

  services.prowlarr.enable = true;
}
