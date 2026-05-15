{
  aegix.github-mcp-server = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.github-mcp-server ];
      };
  };
}
