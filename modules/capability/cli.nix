{
  aegix.cli = {
    homeManager =
      { lib, pkgs, ... }:
      {
        home.packages =
          with pkgs;
          [
            (intelli-shell.overrideAttrs { doCheck = false; })
            bat
            dig
            eza
            fd
            git-worktree-init
            ripgrep
            tldr
            tree
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

  };
}
