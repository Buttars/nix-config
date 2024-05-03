{ config, ... }:
{
  hostConfig = {
    modules = {
      hyprland.enable = false;
      zsh.enable = true;
      kde.enable = true;
      alacritty.enable = true;
      brave.enable = true;
    };
  };


  imports = [
    ../../profiles/common.nix
    ../../profiles/sigint.nix
    ./users
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "field-computer";
  };

  system.stateVersion = "22.05";
}
