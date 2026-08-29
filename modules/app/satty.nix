{ ... }:
{
  aegix.satty.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.satty ];
    };
}
