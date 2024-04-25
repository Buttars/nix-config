{ config, pkgs, ... }: let
  cfg = config.hostConfig.modules;
in {
  imports = [];

  environment.systemPackages = with pkgs; [
    networkmanager
    neovim
    tmux
    tldr
    git
    lf
    tree
    nodejs
    cargo
    gcc
  ];

  programs.zsh.enable = true;

  # TODO: Move this to modules
  services.openssh = {
    enable = true;
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

  i18n.defaultLocale = "en_US.UTF-8";

  networking.networkmanager.enable = true;

}
