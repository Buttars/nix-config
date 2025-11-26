{ pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji

    font-manager
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.sauce-code-pro
    nerd-fonts.noto
    nerd-fonts.inconsolata
    nerd-fonts.roboto-mono
    nerd-fonts.commit-mono

    dejavu_fonts
    noto-fonts
    cantarell-fonts
    inter
    inter-nerdfont
    pixelon
  ];
}
