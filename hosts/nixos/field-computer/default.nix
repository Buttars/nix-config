{ config, ... }:
{
  hostConfig = {
    modules = {
      zsh.enable = true;
      kde.enable = true;
      alacritty.enable = true;
      brave.enable = true;
      docker = {
        enable = true;
        btrfs = false;
      };
    };
  };


  imports = [
    ../../profiles/common.nix
    ../../profiles/sigint.nix
    ../../profiles/audio.nix
    ../../profiles/touch.nix
    ./users
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "field-computer";
    firewall = {
      enabled = false;
    };

  };

  system.stateVersion = "22.05";
}
