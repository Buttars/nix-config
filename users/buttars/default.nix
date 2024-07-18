{ config, lib, home-manager, ... }: {
  users.users.buttars = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    initialPassword = "a$$word";
  };


  home-manager.users.buttars = { config, ... }: {
    home.stateVersion = "22.05";

    home.sessionVariables = {
      BROWSER = "brave";
    };

    home.file.".local/bin/lfub".source = bin/lfub;

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

    programs = {
      zsh.enable = false;
    };

  };
}
