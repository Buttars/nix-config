{
  aegis.features._.fish = {
    programs.fish = {
      enable = true;
      vendor = {
        completions.enable = true;
        config.enable = true;
        functions.enable = true;
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
  };
}
