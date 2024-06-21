{ config, ... }: {
  users.users.buttars = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    initialPassword = "a$$word";
  };

  
  home-manager.users.buttars = { ... }: {
    home.stateVersion = "22.05";

    home.sessionVariables = {
      BROWSER = "brave";
    };

    home.file.".config/hypr".source = ../../../config/hypr;

    programs = {
      zsh.enable = true;
      # neovim.enable = true;
    };

    programs.tmux = {
      enable = true;
      shortcut = "Space";
      keyMode = "vi";
    };

    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        #"$mod" = "SUPER";
        "$mod" = "MOD4";
        bind = [
	  "$mod, q, killactive"
          "$mod, w, exec, $BROWSER"
          "$mod, RETURN, exec, alacritty"
        ];

      };
    };
  };
}
