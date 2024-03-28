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
      tmux.enable = true;
      # neovim.enable = true;
    };

  };
}
