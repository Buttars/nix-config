{ hostname, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../common/core
    ../common/users/buttars

    ../common/features/systemd-boot.nix
    ../common/features/zsa.nix
    ../common/features/syncthing.nix
    ../common/features/audio.nix
    ../common/features/fonts.nix
  ];

  networking = {
    hostName = hostname;
    networkmanager.enable = true;
    firewall.enable = false;
  };
}
