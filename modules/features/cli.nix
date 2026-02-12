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
            intelli-shell
            nix-search-tv
            tldr
            watch
            wikiman
            zoxide
          ]
          ++ lib.optionals pkg.stdenv.isLinux [
            trashy
          ];

        programs.direnv = {
          enable = true;
          nix-direnv.enable = true;
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
            sesh
            sshs
            yazi
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
