# To add a new device:
#   1. Open http://localhost:8384 on an already-configured machine.
#   2. Click "Add Remote Device" and paste the new device's ID (found via Actions > Show ID on that device).
#   3. Accept the incoming device request on the new device when prompted.
#   4. Share the desired folders with the new device via the web UI.
#   5. Once confirmed working, set overrideDevices = true and overrideFolders = true,
#      declare the new device under settings.devices, and add it to each folder's devices list.
{ __findFile, ... }:
{
  aegix.syncthing = {
    nixos =
      { config, ... }:
      let
        stUser = config.services.syncthing.user;
        homeDir = config.users.users.${stUser}.home;
      in
      {
        services.syncthing = {
          enable = true;
          dataDir = homeDir;
          overrideDevices = false;
          overrideFolders = false;
          settings.folders = {
            "Notes".path = "${homeDir}/Documents/Notes";
            "Aegis".path = "${homeDir}/Documents/Aegis";
          };
        };
      };
  };
}
