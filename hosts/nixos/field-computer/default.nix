{ ... }:
{
  host = {
    modules = {
      zsh.enable = true;
      kde.enable = true;
      alacritty.enable = true;
      brave.enable = true;
      docker = {
        enable = true;
        btrfs = false;
      };
    };
    profiles = {
      audio.enable = true;
      sigint.enable = true;
      touch.enable = true;
    };
  };


  imports = [
    ./users
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "field-computer";
    firewall = {
      enabled = false;
    };

  };

  system.stateVersion = "24.05";
}
