{ pkgs, ... }: {
  programs.fish.enable = true;
  programs.direnv.enableFishIntegration = true;

  users.defaultUserShell = pkgs.fish;
}
