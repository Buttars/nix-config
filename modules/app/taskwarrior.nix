{
  # Taskwarrior support for Home Manager
  # Included by: home/* (migrate from home/features/taskwarrior.nix)

  aegix.taskwarrior = {
    homeManager =
      { pkgs, lib, ... }:
      {
        home.packages =
          with pkgs;
          [
            taskwarrior3
            taskwarrior-tui
          ]
          ++ (lib.optionals pkgs.stdenv.isLinux [ taskopen ]);
      };
  };
}
