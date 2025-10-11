{ inputs, ... }:
let
  dotfiles = inputs.dotfiles;
  neovim-config = inputs.neovim-config;
in
{
  home.file = {
    ".config/nvim" = {
      source = "${neovim-config}";
      recursive = true;
    };
    ".config/shell" = {
      source = "${dotfiles}/.config/shell";
      recursive = true;
    };
    ".config/fish" = {
      source = "${dotfiles}/.config/fish";
      recursive = true;
    };
    ".config/tmux".source = "${dotfiles}/.config/tmux";
    ".config/lf".source = "${dotfiles}/.config/lf";
    ".config/zsh".source = "${dotfiles}/.config/zsh";
    ".config/kitty".source = "${dotfiles}/.config/kitty";
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


