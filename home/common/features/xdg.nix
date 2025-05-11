{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    xdg-utils
    xdg-user-dirs
  ];

  xdg = {
    enable = true;
    userDirs.enable = true;
    userDirs.createDirectories = true;
  };

}
