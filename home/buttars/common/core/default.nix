{ pkgs, ... }:
{
  imports = [
    ../../../common/core
    ./dotfiles.nix
    ../features/shell/fish
  ];

  home.packages = with pkgs; [
    zip
    unzip
  ];

  home.sessionVariables = {
    BROWSER = "brave";
    EDITOR = "nvim";
  };

}
