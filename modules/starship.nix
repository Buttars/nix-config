{ config, pkgs, lib, ... }:
let
  cfg = config.host.modules.starship;
in
{
  options.host.modules.starship = {
    enable = lib.mkEnableOption "Enable starship prompt";
  };


  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;
      settings = { };
    };
  };
}
