{ config, ... }:
{
  hostConfig = {
    modules = {
      hyprland.enable = true;
      zsh.enable = true;
      kde.enable = false;
      alacritty.enable = true;
      brave.enable = true;
    };
  };


  imports = [
    ../../profiles/common.nix
    ../../profiles/sigint.nix
    ../../profiles/programming.nix
    ./users
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "buttars-laptop";
  };

  system.stateVersion = "22.05";
}
