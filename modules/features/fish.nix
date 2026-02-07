{
  # Fish shell configuration for Home Manager
  # Included by: home/* (migrate from home/features/cli/fish.nix)
}
{
  features.fish = {
    homeManager = { pkgs, ... }:
      {
        programs.fish = {
          enable = true;

          shellInit = ''
            set fish_greeting
          '';

          loginShellInit = '''';
          interactiveShellInit = '''';
          shellInitLast = '''';
        };
      };
  };
}
