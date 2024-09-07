{ ... }: {
  services.syncthing = {
    enable = true;
    user = "buttars";
    dataDir = "/home/buttars/Documents";
    configDir = "/home/buttars/Documents/.config/syncthing";
  };
}
