{ ... }:
{
  services.syncthing = {
    settings.folders = {
      "Documents" = {
        path = "/home/buttars/Documents";
        devices = {
          "buttars-phone" = {
            id = "VA4QH54-PR7L2WM-3VSJKL4-HUVQ4TR-G3HPXPG-WC6U4P3-WAVUBQI-6SZVXA4";
          };
        };
      };
    };
  };
}
