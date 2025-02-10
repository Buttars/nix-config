{ ... }:
{
  services.syncthing = {
    enable = true;
    user = "buttars";
    configDir = "/home/buttars/.config/syncthing";
    settings = {
      devices = {
        "buttars-phone" = { id = "VA4QH54-PR7L2WM-3VSJKL4-HUVQ4TR-G3HPXPG-WC6U4P3-WAVUBQI-6SZVXA4"; };
      };

      folders = {
        # "Documents" = {
        #   path = "/home/buttars/Documents";
        #   devices = [ "buttars-phone" ];
        # };
      };

      gui = {
        user = "buttars";
        # TODO: Use sops templates to set syncthing password.
      };
    };
  };
}
