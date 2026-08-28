{ ... }:
{
  aegix.devenv = {
    homeManager =
      {
        pkgs,
        ...
      }:
      {
        programs.direnv = {
          enable = true;
          nix-direnv.enable = true;
        };

        home.packages = [ pkgs.devenv ];
      };
  };
}
