{ ... }:
{
  aegix.ai.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.github-mcp-server ];
    };
}
