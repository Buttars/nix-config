{ config, pkgs, ... }:
let
  cfg = config.hostConfig.modules;
in
{
  imports = [ ];

  environment.systemPackages = with pkgs; [
    xdg-utils
    wget
    networkmanager
    nettools
    usbutils
    lsof
    neovim
    tmux
    tmate
    tldr
    lf
    file
    ueberzug
    tree
    nerdfonts
    grim
    slurp
    unzip
    killall
    rsync
    mpv
    nsxiv
    feh
    dosfstools
    ffmpeg
    zathura
    fzf
    bc
    bat
    rustdesk
    pandoc
    sshfs
  ];

  environment.variables.EDITOR = "nvim";

  programs.zsh.enable = true;

  # TODO: Move this to modules
  services.openssh = {
    enable = true;
  };

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "SourceCodePro" "Noto" "Inconsolata" "RobotoMono" ]; })
  ];

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  nixpkgs.config.allowUnfree = true;

  i18n.defaultLocale = "en_US.UTF-8";

  networking.networkmanager.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

}
