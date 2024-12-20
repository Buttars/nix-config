{ config, pkgs, lib, ... }:
let
  cfg = config.host.modules.xremap;
in
{
  options.host.modules.xremap = {
    enable = lib.mkEnableOption "Enable xremap";
  };


  config = lib.mkMerge [
    {
      services.xremap.enable = false;
    }
    (lib.mkIf cfg.enable {
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
    })
  ];
}
