{ ... }: {
  programs.fish = {
    enable = true;

    shellInit = ''
        set fish_greeting
    '';

    loginShellInit = ''
    '';

    interactiveShellInit = ''
    '';

    shellInitLast = ''
    '';
  };
}
