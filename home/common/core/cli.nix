{ pkgs, ... }: {
  home.packages = with pkgs; [
    bat
    gh
    neovim
    sesh
    tldr
    tmux
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
