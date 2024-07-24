{ pkgs, ... }:
{
  home.packages = with pkgs; [
    wget
    git
    htop
    sesh
    neovim
  ];

  home.file.".config/nvim" =
    {
      source = ../users/buttars/config/nvim;
      recursive = true;
    };

  home.stateVersion = "23.05";

  programs.home-manager.enable = true;
}

