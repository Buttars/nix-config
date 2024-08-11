{ pkgs, dotfiles, ... }:
let
  username = "portainer";
in
{
  hostConfig = {
    modules = {
      zsh.enable = true;
      docker.enable = true;
      xremap.enable = false;
    };
    profiles = {
      portainer = {
        enable = true;
        pathToData = "/home/portainer/portainer/data/";
      };
    };
  };

  programs.nix-ld.enable = true;

  imports = [
    ../../../profiles/common.nix
    ../../../profiles/virtualization.nix
    ../../../profiles/server.nix
    ../../../profiles/portainer.nix
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "portainer";
  };

  environment.systemPackages = with pkgs; [
    cargo
    nodejs
  ];

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  home-manager.users.${username} = { config, ... }: {
    home.stateVersion = "22.05";

    home.file.".config/nvim" = {
      source = "${dotfiles}/.config/nvim";
      recursive = true;
    };

    home.file.".config/tmux".source = "${dotfiles}/.config/tmux";
  };

  services.ntp.enable = true;
  services.automatic-timezoned.enable = true;
  services.openssh =
    {
      enable = true;
      passwordAuthentication = true;
    };

  system.stateVersion = "22.05";
}
