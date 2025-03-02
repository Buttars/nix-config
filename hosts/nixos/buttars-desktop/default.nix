{ ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../common/users/buttars

    ../common/features/systemd-boot.nix
    ../common/features/zsa.nix
    ../common/features/syncthing.nix
    ../common/features/audio.nix
    ../common/features/virtualization.nix
    ../common/features/nvidia.nix
    ../common/features/fonts.nix
    ../common/features/gaming
  ];

  programs.dconf.enable = true;

  networking = {
    hostName = "buttars-desktop";
    networkmanager.enable = true;
    firewall.enable = false;
  };

  system.stateVersion = "24.11";
}
