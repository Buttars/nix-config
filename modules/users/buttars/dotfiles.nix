{ ... }:
{
  den.aspects.buttars.homeManager =
    { config, ... }:
    {
      home.file = {
        ".config/nvim".source =
          config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Projects/nix-config/dotfiles/.config/nvim";
      };
    };
}
