{ inputs, ... }: let 
  dotfiles = inputs.dotfiles;
in{
  home.file = {
    # ".local/bin/lfub". source = bin/lfub;
    # ".local/bin/rotdir". source = bin/rotdir;
    ".config/nvim" = { source = "${dotfiles}/.config/nvim"; recursive = true; };
    ".config/shell" = { source = "${dotfiles}/.config/shell"; recursive = true; };
    ".config/fish" = { source = "${dotfiles}/.config/fish"; recursive = true; };
    ".config/hypr".source = "${dotfiles}/.config/hypr";
    ".config/tmux".source = "${dotfiles}/.config/tmux";
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
