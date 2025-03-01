{ ... }:
{
  imports = [
    ./hardware-configuration.nix

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

  programs.dconf.enable = true;

  networking = {
    hostName = "buttars-desktop";
    networkmanager.enable = true;
    firewall.enable = false;
  };

  system.stateVersion = "24.11";
}
