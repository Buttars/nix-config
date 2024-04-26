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
    ./users
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "nixos-vm";
  };

  system.stateVersion = "22.05";
}
