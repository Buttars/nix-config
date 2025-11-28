{ hostname, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../../common/features/nixos/systemd-boot.nix
    ../../common/features/nixos/zsa.nix
    ../../common/features/nixos/syncthing.nix
    ../../common/features/nixos/audio.nix
    ../../common/features/nixos/nvidia.nix
    ../../common/features/nixos/fonts.nix
    ../../common/features/nixos/nfs-utils.nix
  ];

  programs.dconf.enable = true;

  programs.hyprland.enable = true;

  networking = {
    hostName = hostname;
    networkmanager.enable = true;
    firewall.enable = false;
  };
}
