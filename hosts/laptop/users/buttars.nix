{ config, ... }: {
  users.users.buttars = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    initialPassword = "a$$word";
  };
  
  home-manager.users.buttars = { ... }: {
    home.stateVersion = "22.05";


    programs = {
      zsh.enable = true;
      # neovim.enable = true;
    };

    programs.tmux = {
      enable = true;
      shortcut = "Space";
      keyMode = "vi";
    };

    wayland.windowManager.hyprland.settings = {
      "$mod" = "SUPER";
      bind = [
        "$mod, ENTER, exec, alacritty"
      ];
    };

  };
}
