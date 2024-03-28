{ config, ... }:
{
  hostConfig = {
    modules = {
      hyprland.enable = true;
      zsh.enable = true;
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
