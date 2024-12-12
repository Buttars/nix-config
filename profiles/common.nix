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
  ];

  programs.zsh.enable = true;


  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "SourceCodePro" "Noto" "Inconsolata" "RobotoMono" "CommitMono" ]; })
  ];

  networking.networkmanager.enable = true;
}
