{
  aegix.cli = {
    homeManager =
      { lib, pkgs, ... }:
      {
        home.packages =
          with pkgs;
          [
            bat
            eza
            fd
            dig
            git-worktree-init
            (intelli-shell.overrideAttrs { doCheck = false; })
            ripgrep
            tldr
            watch
            wikiman
          ]
          ++ lib.optionals pkgs.stdenv.isLinux [
            trashy
          ];

        programs.television = {
          enable = true;
          enableZshIntegration = true;
          enableFishIntegration = true;
        };

        programs.nix-search-tv = {
          enable = true;
        };

        programs.zoxide = {
          enable = true;
          enableFishIntegration = true;
        };

        programs.direnv = {
          enable = true;
          nix-direnv.enable = true;
          config.global.hide_env_diff = true;
        };
      };

    _.tui = {
      homeManager =
        { pkgs, ... }:
        {
          home.packages = with pkgs; [
            btop
            diffnav
            gh
            gh-dash
            htop
            process-compose
            sshs
          ];
          programs.fzf = {
            enable = true;
            defaultOptions = [ "--color 16" ];
          };
          programs.yazi = {
            enable = true;
            shellWrapperName = "y";
            enableFishIntegration = true;
            enableZshIntegration = true;
            settings.manager = {
              show_hidden = true;
              sort_by = "natural";
              sort_dir_first = true;
            };
          };
        };
    };

    _.aws = {
      homeManager =
        { pkgs, ... }:
        {
          home.packages = with pkgs; [
            awscli2
            terraform
          ];
        };

    };

    _.git = {
      homeManager =
        { pkgs, ... }:
        {
          home.packages = with pkgs; [
            delta
          ];
          programs.delta.enableGitIntegration = true;
          programs.git = {
            enable = true;
            lfs.enable = true;
            settings = {
              log.decorate = "short";
              log.abbrevCommit = "true";
              log.format = "oneline";
              format.pretty = "oneline";
              push.autoSetupRemote = true;
              pull.rebase = true;
              core.pager = "delta";
              pager.diff = "diffnav";
            };
          };
        };
    };

    _.jj = {
      homeManager =
        { ... }:
        {
          programs.fish.interactiveShellInit = ''jj util completion fish | source'';
          programs.zsh.initContent = ''source <(jj util completion zsh)'';
          programs.jujutsu = {
            enable = true;
            settings = {
              git.colocate = true;
              git.push-bookmark-prefix = "wip/";
              ui.default-command = "log";
              ui.pager = "less -FRX";
              ui.diff-editor = ["nvim" "-c" "DiffEditor $left $right $output"];
              ui.diff-instructions = false;
              ui.diff-formatter = "delta";
              ui.merge-editor = "nvim-fugitive";
              revset-aliases.trunk = "latest(remote_bookmarks(exact:main, exact:origin) | remote_bookmarks(exact:master, exact:origin))";
              revset-aliases.mine = "author(self)";
              revset-aliases.wip = "description(exact:'')";
              revset-aliases.stack = "ancestors(@ ~ trunk(), 2..)";
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
              aliases.bm = [ "bookmark" "set" "-r" "@" ];
              aliases.tidy = [ "abandon" "empty() & ancestors(@) & ~trunk()" ];
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
  };
}
