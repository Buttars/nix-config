{ lib, ... }:
{
  programs.fish.shellInit = ''
    set -Ux XDG_CONFIG_HOME $HOME/.config
    set -Ux XDG_DATA_HOME $HOME/.local/share
    set -Ux XDG_CACHE_HOME $HOME/.cache
    set -Ux INPUTRC $XDG_CONFIG_HOME/shell/inputrc
  '';

  home.sessionVariables = lib.mkDefault {
    EDITOR = "nvim";
    TERMINAL = "kitty";
    BROWSER = "brave";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_CACHE_HOME = "$HOME/.cache";
    INPUTRC = "$XDG_CONFIG_HOME/shell/inputrc";
  };
}
