{ pkgs, dotfiles, ... }:
let
  username = "buttars";
in
{
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" "libvirtd" ];
    initialPassword = "a$$word";
  };

  home-manager.backupFileExtension = "backup";

  home-manager.users.${username} = { config, ... }: {
    home.stateVersion = "22.05";

    imports = [
      ../../home-manager/cowsay.nix
      ../../home-manager/alacritty.nix
      ../../home-manager/element-desktop.nix
      # ../../home-manager/tui-task-management.nix
      ../../home-manager/gimp.nix
    ];

    home.sessionVariables = {
      BROWSER = "brave";
      EDITOR = "nvim";
    };

    home.file.".local/bin/lfub". source = bin/lfub;
    home.file.".local/bin/rotdir". source = bin/rotdir;

    home.file.".config/superfile" =
      {
        source = "${dotfiles}/.config/superfile";
        recursive = true;
      };


    home.file.".config/nvim" =
      {
        source = "${dotfiles}/.config/nvim";
        recursive = true;
      };

    home.file.".config/shell" =
      {
        source = "${dotfiles}/.config/shell";
        recursive = true;
      };

    home.file.".config/hypr".source = "${dotfiles}/.config/hypr";
    home.file.".config/tmux".source = "${dotfiles}/.config/tmux";
    home.file.".config/lf".source = "${dotfiles}/.config/lf";
    home.file.".config/zsh".source = "${dotfiles}/.config/zsh";
    home.file.".config/alacritty".source = "${dotfiles}/.config/alacritty";
    home.file.".config/rofi".source = "${dotfiles}/.config/rofi";
    home.file.".config/waybar".source = "${dotfiles}/.config/waybar";
    home.file.".zprofile".source = "${dotfiles}/.config/shell/profile";
    home.file.".config/nixpkgs/config.nix" = {
      text = ''
        {
          allowUnfree = true;
        }
      '';
    };
  };
}
