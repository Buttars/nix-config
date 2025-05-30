{ lib, ... }:
{
  programs.fish.interactiveShellInit = ''
    source $HOME/.config/sops-nix/secrets/rendered/neovim-avante.env
  '';

  home.sessionVariables = lib.mkDefault {
    EDITOR = "nvim";
    TERMINAL = "kitty";
    BROWSER = "brave";
    INPUTRC = "$XDG_CONFIG_HOME/shell/inputrc";
  };
}
