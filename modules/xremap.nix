{ config, lib, pkgs, ... }: let
  cfg = config.hostConfig.modules.xremap;
in {
  options.hostConfig.modules.xremap = {
    enable = lib.mkEnableOption "Enable xremap";
  };


  config = lib.mkIf cfg.enable {
  };
}
