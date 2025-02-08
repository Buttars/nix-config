{ lib, config, ... }: {
  services.syncthing = {
    enable = true;
    settings.gui = {
      user = "buttars";
      # TODO: Use sops templates to set syncthing password.
    };
  };
}
