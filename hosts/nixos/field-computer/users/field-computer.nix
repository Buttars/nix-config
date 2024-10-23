{ config, ... }: {
  users.users.field-computer = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "plugdev" "docker" ];
    initialPassword = "a$$word";
  };

  home-manager.users.field-computer = { ... }: {
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

  };
}
