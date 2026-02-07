{ stateVersion, pkgs, ... }:
{
  imports = [
    ./cli.nix
    ./git.nix
    ./neovim.nix
  ];

  home.packages = with pkgs; [
    nil
  ];

  home.stateVersion = stateVersion;
}
