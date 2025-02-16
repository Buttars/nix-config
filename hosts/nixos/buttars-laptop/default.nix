{ ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../common/core
    ../common/users/buttars

    ../common/optionals/systemd-boot.nix
    ../common/optionals/zsa.nix
    ../common/optionals/syncthing.nix
    ../common/optionals/audio.nix
    ../common/optionals/virtualization.nix
    ../common/optionals/nvidia.nix
    ../common/optionals/fonts.nix
    ../common/optionals/gaming
  ];

  networking = {
    hostName = "buttars-laptop";
    networkmanager.enable = true;
    firewall.enable = false;
  };

  system.stateVersion = "24.11";
}
