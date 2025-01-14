{ pkgs, config, ... }: {
  users.users.buttars = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = ["wheel" "networkmanager"];
  };

  home-manager.users.buttars = import ../../../../../home/buttars/${config.networking.hostName};
}
