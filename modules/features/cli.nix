{
  aegis.cli = {
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
            intelli-shell
            nix-search-tv
            ripgrep
            tldr
            watch
            wikiman
            zoxide
          ]
          ++ lib.optionals pkgs.stdenv.isLinux [
            trashy
          ];

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
  };
}
