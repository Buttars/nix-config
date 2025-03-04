{ pkgs, dotfiles, ... }:
{
  home.packages = with pkgs; [
    wget
    git
    htop
    sesh
    neovim
    kitty
    zoxide
    google-chrome
    tldr
    gh
  ];

  programs.git = {
    enable = true;
    delta.enable = true;
    userName = "Landon Buttars";
    userEmail = "66702865+landon-buttars-wgu@users.noreply.github.com";
    extraConfig = {
      log.decorate = "short";
      log.abbrevCommit = "true";
      log.format = "oneline";
      push.autoSetupRemote = true;
    };
  };

  home.file = {
    ".config/nvim" = {
      source = "${dotfiles}/.config/nvim";
      recursive = true;
    };
    ".config/tmux" = { source = "${dotfiles}/.config/tmux"; recursive = true; };
    ".config/kitty" = { source = "${dotfiles}/.config/kitty"; recursive = true; };
    ".config/zsh" = { source = "${dotfiles}/.config/zsh"; recursive = true; };
    ".config/shell" = { source = "${dotfiles}/.config/shell"; recursive = true; };
  };

  programs.home-manager.enable = true;
  home.stateVersion = "24.11";
}

