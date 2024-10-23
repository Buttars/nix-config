{ pkgs, dotfiles, ... }:
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
      source = "${dotfiles}/.config/nvim";
      recursive = true;
    };
  home.file.".config/tmux" =
    {
      source = "${dotfiles}/.config/tmux";
      recursive = true;
    };

  home.stateVersion = "24.05";

  programs.home-manager.enable = true;
}

