{
  aegix.newsboat.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.newsboat ];
    };
}
