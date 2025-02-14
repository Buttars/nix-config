{ ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../common/core
    ../common/users/buttars

    ../common/optionals/systemd-boot.nix
    ../common/optionals/steam.nix
    ../common/optionals/zsa.nix
    ../common/optionals/syncthing.nix
    ../common/optionals/audio.nix
    ../common/optionals/virtualization.nix
    ../common/optionals/nvidia.nix
    ../common/optionals/fonts.nix
  ];

  networking = {
    hostName = "buttars-desktop";
    networkmanager.enable = true;
    firewall.enable = false;
  };

  system.stateVersion = "24.11";
}
