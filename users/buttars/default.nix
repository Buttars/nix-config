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
    home.stateVersion = "24.05";

    home.packages = with pkgs; [
      cowsay
      alacritty
      element-desktop
      gimp
    ];

    imports = [
      # ../../home-manager/tui-task-management.nix
    ];

    home.sessionVariables = {
      BROWSER = "brave";
      EDITOR = "nvim";
    };

    home.file = {
      ".local/bin/lfub". source = bin/lfub;
      ".local/bin/rotdir". source = bin/rotdir;
      ".config/superfile" = { source = "${dotfiles}/.config/superfile"; recursive = true; };
      ".config/nvim" = { source = "${dotfiles}/.config/nvim"; recursive = true; };
      ".config/shell" = { source = "${dotfiles}/.config/shell"; recursive = true; };
      ".config/hypr".source = "${dotfiles}/.config/hypr";
      ".config/tmux".source = "${dotfiles}/.config/tmux";
      ".config/lf".source = "${dotfiles}/.config/lf";
      ".config/zsh".source = "${dotfiles}/.config/zsh";
      ".config/alacritty".source = "${dotfiles}/.config/alacritty";
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
  };
}
