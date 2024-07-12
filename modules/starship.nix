{ config, pkgs, lib, ... }:
let
  cfg = config.hostConfig.modules.starship;
in
{
  options.hostConfig.modules.starship = {
    enable = lib.mkEnableOption "Enable starship prompt";
  };


  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;
      settings = { };
    };
  };
}
