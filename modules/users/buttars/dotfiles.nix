{ inputs, ... }:
{
  den.aspects.buttars.homeManager =
    let
      inherit (inputs) dotfiles;
    in
    {
      config,
      ...
    }:
    {
      home.file = {
        ".config/nvim".source =
          config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Projects/nix-config/dotfiles/.config/nvim";
        ".config/rofi".source = "${dotfiles}/.config/rofi";
        ".config/waybar".source = "${dotfiles}/.config/waybar";
      };
    };
}
