{ ... }: {
  imports = [
    ./cli.nix
    ./git.nix
  ];

  home.stateVersion = "24.11";
}
