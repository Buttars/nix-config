{ config, lib, ... }: {
  users.users.buttars = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    initialPassword = "a$$word";
  };

  home-manager.users.buttars = { ... }: {
    home.stateVersion = "24.05";


    programs = {
      zsh.enable = true;
      # neovim.enable = true;
    };

    programs.tmux = {
      enable = true;
      shortcut = "Space";
      keyMode = "vi";
    };

    programs.neovim = {
      enable = true;
    };

    xdg.configFile."nvim/init.lua".source = ./config/nvim/init.lua;

  };
}
