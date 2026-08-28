{
  aegix.ai._.claude.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.claude-code ];
    };
}
