{ inputs, ... }:
{
  flake-file.inputs.dotfiles = {
    url = "https://github.com/Buttars/.dotfiles";
    type = "git";
    ref = "main";
    rev = "a52773c370f6837c666292e24adbbffe43a61de1";
    submodules = false;
    flake = false;
  };

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
