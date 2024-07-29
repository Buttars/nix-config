{ config, ... }:
{
  hostConfig = {
    modules = {
      hyprland.enable = false;
      zsh.enable = true;
    };
  };


  imports = [
    ../../../profiles/common.nix
    ../../../profiles/programming.nix
    ./users
  ];

  networking = {
    hostName = "nixos-vm";
    wireless.enable = false;
  };

  system.stateVersion = "22.05";
}
