{ config, ... }:
{
  hostConfig = {
    modules = {
      hyprland.enable = true;
      zsh.enable = true;
      kde.enable = false;
      alacritty.enable = true;
      brave.enable = true;
      discord.enable = true;
      obsidian.enable = true;
    };
  };


  imports = [
    ../../profiles/common.nix
    ../../profiles/audio.nix
    ./users
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "buttars-desktop";
  };

  system.stateVersion = "22.05";
}
