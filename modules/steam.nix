{ config, lib, pkgs, ... }:
let
  cfg = config.host.modules.steam;
in
{
  options.host.modules.steam = {
    enable = lib.mkEnableOption "Enable Steam";
  };


  config = lib.mkIf cfg.enable {
    programs.steam.enable = true;

    environment.systemPackages = with pkgs; [
      mangohud
    ];
  };
}
