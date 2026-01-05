{
  lib,
  inputs,
  config,
  ...
}:
let
  dotfiles = inputs.dotfiles;
in
{
  home.file = {
    ".config/nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/dotfiles/.config/nvim";
      recursive = true;
    };
    ".config/shell" = {
      source = "${dotfiles}/.config/shell";
      recursive = true;
    };

    ".config/direnv/direnv.toml".text = lib.mkIf config.programs.direnv.enable ''
      [global]
      hide_env_diff = true
    '';

    # ".config/hypr".source = "${dotfiles}/.config/hypr";
    ".config/lf".source = "${dotfiles}/.config/lf";
    ".config/zsh".source = "${dotfiles}/.config/zsh";
    ".config/alacritty".source = "${dotfiles}/.config/alacritty";
    ".config/kitty".source = "${dotfiles}/.config/kitty";
    ".config/rofi".source = "${dotfiles}/.config/rofi";
    ".config/waybar".source = "${dotfiles}/.config/waybar";
    ".zprofile".source = "${dotfiles}/.config/shell/profile";
    ".config/nixpkgs/config.nix" = {
      text = ''
        {
          allowUnfree = true;
        }
      '';
    };
  };
}
