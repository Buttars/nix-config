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
            ui.pager = "less -FRX";
            ui.diff.tool = [ "diffnav" "$left" "$right" ];
            # ui.diff-editor = [ "nvim" "-d"];
            merge-tools.vimdiff = { program = "nvim"; };
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
