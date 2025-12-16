{ ... }:
{
  imports = [
    ../../common/features/nixos/systemd-boot.nix
    ../../common/features/nixos/nfs-utils.nix
  ];

  networking = {
    networkmanager.enable = true;
    firewall.enable = false;
  };
}
