{ pkgs, dotfiles, stateVersion, ... }:
let
  username = "buttars";
in
{
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" "libvirtd" "postgres" "adbusers" ];
    initialPassword = "a$$word";
    useDefaultShell = true;
  };

  home-manager.backupFileExtension = "backup";

  home-manager.users.${username} = { config, ... }: {

    programs.starship.enable = true;
    programs.fish = {
      enable = true;

      shellInit = ''
        set fish_greeting
      '';

      loginShellInit = ''
      '';

      interactiveShellInit = ''
      '';

      shellInitLast = ''
      '';
    };

    home.packages = with pkgs; [
      cowsay
      alacritty
      element-desktop
      gimp
      gh
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

    home.stateVersion = stateVersion;
  };
}
