{ pkgs, ... }: {
  home.packages = with pkgs; [
    bat
    gh
    htop
    neovim
    sesh
    sshs
    tldr
    tmux
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
