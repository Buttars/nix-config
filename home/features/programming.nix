{ pkgs, ... }:
{
  home.packages = with pkgs; [
    atac
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
