{ config, lib, pkgs, ... }:
let
  cfg = config.hostConfig.profiles.gaming;
in
{
  options.hostConfig.profiles.gaming = {
    enable = lib.mkEnableOption "Enable gaming profiles.";
  };

  config = lib.mkIf cfg.enable {
    programs.steam.enable = true;
    programs.steam.gamescopeSession.enable = true;

    environment.systemPackages = with pkgs; [
      mangohud
      protonup
    ];

    programs.gamemode.enable = true;
  };
}
