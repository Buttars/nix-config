{ config, ... }:
{
  hostConfig = {
    modules = {
      hyprland.enable = false;
      zsh.enable = true;
      kde.enable = true;
    };
  };


  imports = [
    ../../profiles/common.nix
    ./users
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "nixos-vm";
    wireless.enable = false;
  };

  system.stateVersion = "22.05";
}
