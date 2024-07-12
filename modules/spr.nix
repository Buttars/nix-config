{ config, lib, pkgs, ... }:
let
  cfg = config.hostConfig.modules.spr;
in
{
  options.hostConfig.modules.spr = {
    enable = lib.mkEnableOption "Enable spr for git";
  };


  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      spr
    ];
  };
}
