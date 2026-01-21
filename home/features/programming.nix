{ pkgs, ... }:
{
  home.packages = with pkgs; [
    atac
    compose2nix
    delta
    devenv
    devpod
    dig
    git
    lazydocker
    nixpkgs-fmt
    ripgrep
  ];

  programs.direnv.enable = true;
}
