{ config, lib, ... }: let 
  cfg = config.hostConfig.modules.kde;
in {
  options.hostConfig.modules.kde = {
    enable = lib.mkEnableOption "Enable KDE desktop environemnt";
  };

  config = lib.mkIf cfg.enable {
    services.desktopManager.plasma6.enable = true;
  };
}
