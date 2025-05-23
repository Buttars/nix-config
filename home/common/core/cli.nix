{ pkgs, ... }: {
  home.packages = with pkgs; [
    bat
    gh
    sshs
    neovim
    sesh
    tldr
    tmux
    zoxide
    yazi
    wikiman
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
