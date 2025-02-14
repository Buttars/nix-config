{ ... }: {
  imports = [
    ./gamemode.nix
  ];

  programs.steam.enable = true;
}
