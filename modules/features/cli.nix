{
  aegis.features._.cli = {
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
  };
}
