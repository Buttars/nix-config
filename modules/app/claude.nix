{
  aegix.claude.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.claude-code ];
    };
}
