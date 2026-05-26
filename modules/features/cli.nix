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
            intelli-shell
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
          programs.delta.enableJujutsuIntegration = true;
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
          programs.jujutsu.enable = true;
        };
    };
  };
}
