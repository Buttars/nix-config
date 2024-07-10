{ config, pkgs, lib, ... }: let
  cfg = config.hostConfig.modules.xremap;
in {
  options.hostConfig.modules.xremap = {
    enable = lib.mkEnableOption "Enable xremap";
  };


  config = lib.mkIf cfg.enable {
    services.xremap.withWlroots = true;
    services.xremap.config.modmap = [
      {
        name = "Global";
        remap = { 
          "CapsLock" = {
            held = "WIN_L";
            alone = "ESC";
            alone_timeout_milis = 500;
          };
        };
      }
    ];
  };
}
