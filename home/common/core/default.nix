{ ... }: {
  imports = [
    ./cli.nix
    ./git.nix
    ./neovim.nix
  ];

  home.stateVersion = "24.11";
}
