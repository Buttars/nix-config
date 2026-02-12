{
  aegis.cli = {
    homeManager =
      { lib, pkgs, ... }:
      {
        home.packages =
          with pkgs;
          [
            bat
            btop
            diffnav
            eza
            fd
            gh
            gh-dash
            htop
            intelli-shell
            neovim
            nix-search-tv
            process-compose
            sesh
            sshs
            tldr
            tmux
            watch
            wikiman
            yazi
            zoxide
          ]
          ++ lib.optionals pkg.stdenv.isLinux [
            trashy
          ];

        programs.fzf = {
          enable = true;
          defaultOptions = [ "--color 16" ];
        };

        programs.direnv = {
          enable = true;
          nix-direnv.enable = true;
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
            diffnav
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
