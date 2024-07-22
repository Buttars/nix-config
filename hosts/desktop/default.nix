{ config, pkgs, xremap-flake, ... }:
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
      starship.enable = true;
      fastfetch.enable = true;
      xremap.enable = true;
      spr.enable = true;
      zoxide.enable = true;
      nvidia.enable = true;
    };
  };

  programs.nix-ld.enable = true;

  imports = [
    ../../profiles/common.nix
    ../../profiles/audio.nix
    ../../profiles/programming.nix
    ../../profiles/zsa.nix
    ../../profiles/tui-file-manager.nix
    ./users
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "buttars-desktop";
  };

  services.ntp.enable = true;
  services.automatic-timezoned.enable = true;

  system.stateVersion = "22.05";
}
