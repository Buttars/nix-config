{ config, lib, pkgs, home-manager, ... }:
let
  username = "buttars";
in
{
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    initialPassword = "a$$word";
  };

  home-manager.users.${username} = { config, ... }: {
    home.stateVersion = "22.05";

    imports = [
      ../../home-manager/cowsay.nix
      ../../home-manager/alacritty.nix
      ../../home-manager/element-desktop.nix
    ];

    home.sessionVariables = {
      BROWSER = "brave";
      EDITOR = "nvim";
    };

    home.file.".local/bin/lfub". source = bin/lfub;
    home.file.".local/bin/rotdir". source = bin/rotdir;

    home.file.".config/nvim" =
      {
        source = config/nvim;
        recursive = true;
      };

    home.file.".config/shell" =
      {
        source = config/shell;
        recursive = true;
      };

    home.file.".config/hypr".source = config/hypr;
    home.file.".config/tmux".source = config/tmux;
    home.file.".config/lf".source = config/lf;
    home.file.".config/zsh".source = config/zsh;
    home.file.".config/alacritty".source = config/alacritty;
    home.file.".config/rofi".source = config/rofi;
    home.file.".config/waybar".source = config/waybar;
    home.file.".zprofile".source = config/shell/profile;
    home.file.".config/nixpkgs/config.nix" = {
      text = ''
        {
          allowUnfree = true;
        }
      '';
    };
  };
}
