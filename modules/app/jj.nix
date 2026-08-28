{
  aegix.jj = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.jj-hunk ];
        programs.fish.interactiveShellInit = "jj util completion fish | source";
        programs.zsh.initContent = "source <(jj util completion zsh)";
        programs.jujutsu = {
          enable = true;
          settings = {
            git.colocate = true;
            git.push-bookmark-prefix = "wip/";
            ui.default-command = "log";
            ui.pager = "less -FRX";
            ui.diff-editor = [
              "nvim"
              "-c"
              "DiffEditor $left $right $output"
            ];
            ui.diff-instructions = false;
            ui.diff-formatter = "delta";
            ui.merge-editor = "nvim-fugitive";
            revset-aliases.trunk = "latest(remote_bookmarks(exact:main, exact:origin) | remote_bookmarks(exact:master, exact:origin))";
            revset-aliases.mine = "author(self)";
            revset-aliases.wip = "description(exact:'')";
            revset-aliases.stack = "ancestors(@ ~ trunk(), 2..)";
            merge-tools.delta.diff-args = [
              "--side-by-side"
              "$left"
              "$right"
              "--width=$width"
            ];
            merge-tools.delta.diff-expected-exit-codes = [
              0
              1
            ];
            merge-tools.nvim-fugitive = {
              program = "nvim";
              merge-args = [
                "-c"
                "Gvdiffsplit!"
                "$output"
              ];
            };
            merge-tools.jj-hunk = {
              program = "jj-hunk";
              edit-args = [
                "select"
                "$left"
                "$right"
              ];
            };
            aliases.diffnav = [
              "diff"
              "--config=ui.diff-formatter=':git'"
              "--config=ui.pager='diffnav'"
            ];
            aliases.bm = [
              "bookmark"
              "set"
              "-r"
              "@"
            ];
            aliases.tidy = [
              "abandon"
              "empty() & ancestors(@) & ~trunk()"
            ];
            fix.tools = {
              nixfmt = {
                command = [
                  "nixfmt"
                  "-"
                ];
                patterns = [ "glob:**/*.nix" ];
              };
              prettier = {
                command = [
                  "prettier"
                  "--stdin-filepath"
                  "$path"
                ];
                patterns = [
                  "glob:**/*.json"
                  "glob:**/*.yaml"
                  "glob:**/*.yml"
                  "glob:**/*.md"
                ];
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
