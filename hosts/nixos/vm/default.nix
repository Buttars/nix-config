{ ... }:
{
  hostConfig = {
    modules = {
      hyprland.enable = false;
      zsh.enable = true;
    };
    profiles = {
      programming.enable = true;
    };
  };


  imports = [
    ./users
  ];

  networking = {
    hostName = "nixos-vm";
    wireless.enable = false;
  };

  system.stateVersion = "22.05";
}
