{ ... }:
{
  imports = [
    ./aliases.nix
    ./env-vars.nix
    ./functions.nix
    ./graphical-session.nix
    ./sesh.nix
  ];

  programs.fish.enable = true;
}

