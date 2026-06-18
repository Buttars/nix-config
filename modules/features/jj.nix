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
            ui.diff-formatter = "delta";
            ui.merge-editor = "nvim-fugitive";
            merge-tools.delta.diff-args = [ "--side-by-side" "$left" "$right" "--width=$width" ];
            merge-tools.delta.diff-expected-exit-codes = [ 0 1 ];
            merge-tools.nvim-fugitive = {
              program = "nvim";
              merge-args = [
                "-c"
                "Gvdiffsplit!"
                "$output"
              ];
            };
            aliases.diffnav = [ "diff" "--config=ui.diff-formatter=':git'" "--config=ui.pager='diffnav'" ];
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
