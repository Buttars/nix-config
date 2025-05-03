{ ... }: {
  services.jellyfin = {
    enable = true;
    dataDir = "/srv/services/jellyfin/data";
    configDir = "/srv/services/jellyfin/config";
  };
}
