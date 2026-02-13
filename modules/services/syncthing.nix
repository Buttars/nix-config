{
  aegis.syncthing =
    let
      devices = {
        buttars-laptop.id = "VA4QH54-PR7L2WM-3VSJKL4-HUVQ4TR-G3HPXPG-WC6U4P3-WAVUBQI-6SZVXA4";
      };
      all_devices = builtins.attrNames devices;
      syncthing = folders: {
        enable = true;
        settings = {
          inherit devices;
          folders = lib.mkDefault folders || { };
        };
      };
    in
    {
      provides.client.homeManager.services = {
        inherit syncthing;
      };
      provides.server.nixos.services.syncthing = lib.mkMerge [
        syncthing
        {
          openDefaultPorts = true;
          devices = lib.mapAttrs (name: value: value // { autoAcceptFolders = true; }) devices;
        }
      ];
    };
}
