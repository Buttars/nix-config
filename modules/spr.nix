{ config, lib, pkgs, ... }:
let
  cfg = config.host.modules.spr;
in
{
  options.host.modules.spr = {
    enable = lib.mkEnableOption "Enable spr for git";
  };


  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      spr
    ];
  };
}
