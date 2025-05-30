{ lib, ... }:
{
  '';

  home.sessionVariables = lib.mkDefault {
    EDITOR = "nvim";
    TERMINAL = "kitty";
    BROWSER = "brave";
    INPUTRC = "$XDG_CONFIG_HOME/shell/inputrc";
  };
}
