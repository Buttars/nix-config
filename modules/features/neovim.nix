{
  aegix.neovim = {
    homeManager =
      { pkgs, ... }:
      {
        programs.neovim = {
          enable = true;
          viAlias = true;
          vimAlias = true;
          vimdiffAlias = true;
        };

        home.packages = with pkgs; [
          imagemagick
          statix
          opencode
        ];
      };
  };
}
