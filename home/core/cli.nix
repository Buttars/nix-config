{ pkgs, ... }:
{
  home.packages = with pkgs; [
    bat
    btop
    diffnav
    eza
    fd
    gh
    gh-dash
    htop
    intelli-shell
    neovim
    nix-search-tv
    process-compose
    sesh
    sshs
    tldr
    tmux
    trashy
    watch
    wikiman
    yazi
    zoxide
  ];

  programs.fzf = {
    enable = true;
    defaultOptions = [ "--color 16" ];
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
