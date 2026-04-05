{ __findFile, ... }:
{
  den.aspects.buttars-laptop = {
    includes = [
      <aegis/audio>
      <aegis/fonts>
      <aegis/zsa>
      <aegis/sops>
      <aegis/theming>
    ];
    nixos = {
      imports = [
        ./_disko.nix
        ./_stylix.nix
      ];

      programs.fish.enable = true;
      programs.dconf.enable = true;
      programs.hyprland.enable = true;
      networking = {
        networkmanager.enable = true;
        firewall.enable = false;
      };
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.initrd.availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usb_storage"
        "usbhid"
        "sd_mod"
        "iwlwifi"
      ];
      boot.initrd.kernelModules = [ ];
      boot.initrd.systemd.enable = true;
      boot.kernelModules = [
        "kvm-intel"
        "iwlmvm"
      ];
      boot.extraModulePackages = [ ];
      nixpkgs.hostPlatform = "x86_64-linux";
      hardware.cpu.intel.updateMicrocode = true;
      hardware.enableRedistributableFirmware = true;

      users.users.buttars = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
          "video"
          "audio"
        ];
      };

    };
  };
}
