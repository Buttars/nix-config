{ stateVersion, ... }: {
  imports = [
    ./cli.nix
    ./git.nix
    ./neovim.nix
  ];

  home.stateVersion = stateVersion;
}
