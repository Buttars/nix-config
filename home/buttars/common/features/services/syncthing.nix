{ ... }: {
  services.syncthing = {
    settings.folders = {
      "Documents" = {
        path = "/home/buttars/Documents";
        devices = [];
      };
    };
  };
}
