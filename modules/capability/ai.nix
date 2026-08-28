{
  aegix.ai = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          github-mcp-server
        ];
      };
  };
}
