{
  aegix.fish = {
    nixos = {
      programs.fish = {
        enable = true;
        vendor = {
          completions.enable = true;
          config.enable = true;
          functions.enable = true;
        };
      };
    };

    homeManager =
      { pkgs, ... }:
      {
        programs.fish = {
          enable = true;

          shellInit = ''
            set fish_greeting
          '';

          loginShellInit = "";
          interactiveShellInit = "";
          shellInitLast = "";
        };
      };

    # Per-user fish tweaks (aliases, functions, env, sesh, graphical-session) have
    # been moved to modules/users/buttars/fish.nix so they can be applied only for
    # the `buttars` aspect. Keep this file focused on the base fish configuration.
  };
}
