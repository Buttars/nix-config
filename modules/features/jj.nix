{
  aegix.jj = {
    homeManager =
      { ... }:
      {
        programs.jujutsu = {
          enable = true;
          settings = {
            git.colocate = true;
            ui.diff-editor = "vimdiff";
            merge-tools.vimdiff = {
              program = "nvim";
              diff-args = [
                "-d"
                "$left"
                "$right"
              ];
            };
            fix.tools = {
              nixfmt = {
                command = [ "nixfmt" ];
                patterns = [ "glob:**/*.nix" ];
              };
              prettier = {
                command = [
                  "prettier"
                  "--stdin-filepath"
                  "$path"
                ];
                patterns = [ "glob:**/*.{json,yaml,yml,md}" ];
              };
              shfmt = {
                command = [ "shfmt" ];
                patterns = [ "glob:**/*.sh" ];
              };
            };
          };
        };
      };
  };
}
