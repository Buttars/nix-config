{
  # XDG user dirs and utilities for Home Manager
  # Included by: home/* (migrate from home/features/xdg.nix)

  aegis.features._.xdg = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          xdg-utils
          xdg-user-dirs
        ];

        xdg = {
          enable = true;
          userDirs.enable = true;
          userDirs.createDirectories = true;
        };
      };
  };
}
