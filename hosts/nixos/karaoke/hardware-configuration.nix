{ pkgs, lib, ... }: {
  boot = {
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = lib.mkForce false;
    };

    kernelParams = [ "cma=32M" ];
    kernelPackages = pkgs.linuxPackages_6_1;
  };

  boot.initrd = {
    availableKernelModules = [
      "usbhid"
      "usb_storage"
      "vc4"
      "pcie_brcmstb" # required for the pcie bus to work
      "reset-raspberrypi" # required for vl805 firmware to load
    ];
  };

  # disko.devices = {
  #   disk."mmcblk0" = {
  #     device = "";
  #     type = "disk";
  #     content = {
  #       type = "gpt";
  #       partitions = {
  #         ESP = {
  #           type = "EF00";
  #           size = "500M";
  #           content = {
  #             type = "filesystem";
  #             format = "vfat";
  #             mountpoint = "/boot";
  #           };
  #         };
  #         root = {
  #           size = "100%";
  #           content = {
  #             type = "filesystem";
  #             format = "ext4";
  #             mountpoint = "/";
  #           };
  #         };
  #       };
  #     };
  #   };
  # };

  systemd.services.disko.enable = true;

  # fileSystems = {
  #   "/boot" = {
  #     device = "/dev/disk/by-label/boot";
  #     fsType = "vfat";
  #   };
  #   "/" = {
  #     device = "/dev/disk/by-label/root";
  #     fsType = "ext4";
  #   };
  # };

  hardware.enableRedistributableFirmware = true;

  nixpkgs.hostPlatform = "aarch64-linux";
}
