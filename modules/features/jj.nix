{
  aegix.jj = {
    homeManager =
      { ... }:
      {
        programs.fish.interactiveShellInit = ''jj util completion fish | source'';
        programs.zsh.initContent = ''source <(jj util completion zsh)'';
        programs.jujutsu = {
          enable = true;
          settings = {
            git.colocate = true;
            ui.pager = "diffnav";
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
