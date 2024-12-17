{ pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    # System Utilities
    dosfstools
    gnused
    sshfs
    sshs
    xdg-utils

    # Networking & Connectivity
    networkmanager
    rustdesk
    sshfs

    # Text Editors & Terminal Tools
    bat
    pandoc
    sesh
    tmate

    # Fonts & Appearance
    commit-mono
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
  ];

  programs.zsh.enable = true;


  fonts.packages = with pkgs; [
    nerd-fonts.sauce-code-pro
    nerd-fonts.noto
    nerd-fonts.inconsolata
    nerd-fonts.roboto-mono
    nerd-fonts.commit-mono
  ];

  networking.networkmanager.enable = true;
}
