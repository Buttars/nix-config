# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.initrd.systemd.enable = true;
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/2235480d-bdae-4a8a-8754-128e37664494";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."luks-9d7e0f9b-90ad-4caf-a6ff-69e0fb952bd8".device = "/dev/disk/by-uuid/9d7e0f9b-90ad-4caf-a6ff-69e0fb952bd8";

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/52E2-BF86";
      fsType = "vfat";
    };

  boot.initrd.luks.devices."luks-1f6fe185-d2ae-46e4-bf1d-6b7ed5b9ae6a".device = "/dev/disk/by-uuid/1f6fe185-d2ae-46e4-bf1d-6b7ed5b9ae6a";

  swapDevices = [{ device = "/dev/disk/by-uuid/6a500369-bc2b-4b1d-b3a8-306623a1aafe"; }];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp59s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
