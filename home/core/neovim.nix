{ pkgs, ... }:
{
  home.packages = with pkgs; [
    neovim
    # pngpaste
    imagemagick
    statix
  ];
}
