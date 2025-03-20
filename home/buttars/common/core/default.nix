{ pkgs, ... }:
{
  imports = [
    ../../../common/core
    ./dotfiles.nix
  ];

  home.packages = with pkgs; [
    zip
    unzip
  ];

  home.sessionVariables = {
    BROWSER = "brave";
    EDITOR = "nvim";
  };

  home.stateVersion = "24.11";
}
