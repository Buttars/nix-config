{ config, lib, pkgs, ... }:
let
  cfg = config.hostConfig.modules.vdhcoapp;
in
{
  options.hostConfig.modules.vdhcoapp = {
    enable = lib.mkEnableOption "Enable Brave Browser";
  };


  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      vdhcoapp
    ];
  };
}
