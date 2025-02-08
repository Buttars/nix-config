{ ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../common/core
    ../common/users/buttars

    ../common/optionals/systemd-boot.nix
    ../common/optionals/gamemode.nix
    ../common/optionals/zsa.nix
    ../common/optionals/syncthing.nix
  ];

  networking = {
    hostName = "buttars-desktop";
    networkmanager.enable = true;
  };

  system.stateVersion = "24.11";
}
