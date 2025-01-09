{ ... }:
{
  host = {
    modules = {
      kde.enable = true;
      alacritty.enable = true;
      brave.enable = true;
      docker = {
        enable = true;
        btrfs = false;
      };
    };
    profiles = {
    };
  };


  imports = [
    ../common/optional/audio.nix
    ../common/optional/sigint.nix
    ../common/optional/touch.nix
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
