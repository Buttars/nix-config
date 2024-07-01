{ config,pkgs, ... }:
{
  hostConfig = {
    modules = {
      hyprland.enable = true;
      zsh.enable = true;
      alacritty.enable = true;
      brave.enable = true;
      discord.enable = true;
      obsidian.enable = true;
      docker.enable = true;
      steam.enable = true;
      vdhcoapp.enable = true;
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
