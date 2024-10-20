{ config, lib, pkgs, ... }:
let
  cfg = config.host.modules.brave;
in
{
  options.host.modules.brave = {
    enable = lib.mkEnableOption "Enable Brave Browser";
  };


  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      brave
    ];
  };
}
