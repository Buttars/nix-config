{
  aegix.neovim = {
    os =
      { pkgs, ... }:
      {
        environment.systemPackages = [ pkgs.neovim ];
      };
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          neovim
          imagemagick
          statix
          opencode
        ];
      };
  };
}
