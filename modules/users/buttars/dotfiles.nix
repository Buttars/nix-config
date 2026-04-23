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
        ".config/nvim" = {
          source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/dendritic-from-scratch/dotfiles/.config/nvim";
          recursive = true;
        };
        ".config/rofi".source = "${dotfiles}/.config/rofi";
        ".config/waybar".source = "${dotfiles}/.config/waybar";
      };
    };
}
