{ ... }:
{
  imports = [
    ./dotfiles.nix
  ];

  home.sessionVariables = {
    BROWSER = "brave";
    EDITOR = "nvim";
  };

  home.stateVersion = "24.11";
}
