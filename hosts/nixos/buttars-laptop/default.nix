{ hostname, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../common/users/buttars

    ../common/features/systemd-boot.nix
    ../common/features/zsa.nix
    ../common/features/syncthing.nix
    ../common/features/audio.nix
    ../common/features/nvidia.nix
    ../common/features/fonts.nix
  ];

  programs.dconf.enable = true;

  programs.hyprland.enable = true;

  networking = {
    hostName = hostname;
    networkmanager.enable = true;
    firewall.enable = false;
  };
}
