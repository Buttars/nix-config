{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    mangohud
  ];
  programs.steam.enable = true;
  programs.gamemode.enable = true;
  programs.gamescope.enable = true;
}
