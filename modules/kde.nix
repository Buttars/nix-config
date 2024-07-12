{ config, lib, ... }:
let
  cfg = config.hostConfig.modules.kde;
in
{
  options.hostConfig.modules.kde = {
    enable = lib.mkEnableOption "Enable KDE desktop environemnt";
  };

  config = lib.mkIf cfg.enable {
    services.xserver.enable = true;
    services.desktopManager.plasma6.enable = true;
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = false;
    services.displayManager.defaultSession = "plasma";
  };
}
