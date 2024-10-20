{ config, lib, pkgs, ... }:
let
  cfg = config.host.modules.vdhcoapp;
in
{
  options.host.modules.vdhcoapp = {
    enable = lib.mkEnableOption "Enable Brave Browser";
  };


  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      vdhcoapp
    ];
  };
}
