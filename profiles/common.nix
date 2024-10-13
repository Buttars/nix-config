{ pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    # System Utilities
    dosfstools
    killall
    lsof
    rsync
    gnused
    sshfs
    sshs
    tldr
    tree
    unzip
    usbutils
    wget
    xdg-utils

    # Networking & Connectivity
    nettools
    networkmanager
    rustdesk
    sshfs

    # Text Editors & Terminal Tools
    bat
    fzf
    neovim
    pandoc
    sesh
    tmate
    tmux

    # Fonts & Appearance
    nerdfonts
    nwg-look

    # Media Tools
    ffmpeg

    # Screen & Clipboard Utilities
    cliphist
    grim
    slurp

    # Miscellaneous Tools
    fastfetch
    figlet
    gum
    jq
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

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
