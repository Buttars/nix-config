{
  aegix.alacritty = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.alacritty ];
      };
  };
}
