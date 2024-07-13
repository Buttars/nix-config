{ config, lib, pkgs, ... }:
let
  cfg = config.hostConfig.modules.steam;
in
{
  options.hostConfig.modules.steam = {
    enable = lib.mkEnableOption "Enable Steam";
  };


  config = lib.mkIf cfg.enable {
    programs.steam.enable = true;

    environment.systemPackages = with pkgs; [
      mangohud
    ];
  };
}
