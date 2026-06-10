{ den, __findFile, ... }:
{
  den.hosts.x86_64-linux.buttars-laptop = {
    users.buttars = {
      classes = [ "homeManager" ];
      aspect = den.aspects.buttars;
    };
  };

  den.aspects.buttars-laptop = {
    includes = [
      <aegix/audio>
      <aegix/fish>
      <aegix/hyprland>
      <aegix/fonts>
      <aegix/zsa>
      <aegix/sops>
      <aegix/theming>
      <aegix/syncthing>
    ];
    nixos = {
      imports = [
        ./_disko.nix
        ./_stylix.nix
      ];

      networking = {
        networkmanager.enable = true;
        firewall.enable = false;
      };
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      boot.resumeDevice = "/dev/mapper/crypted";
      # Run: sudo btrfs inspect-internal map-swapfile -r /.swapvol/swapfile
      # Then replace the value below with the output.
      boot.kernelParams = [ "resume_offset=533760" ];

      systemd.sleep.settings.Sleep.HibernateMode = "shutdown";
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

      services.syncthing.user = "buttars";

      home-manager.users.buttars = {
        wayland.windowManager.hyprland.settings = {
          monitor = [
            {
              output = "eDP-1";
              mode = "1920x1080@60";
              position = "0x0";
              scale = 1;
            }
          ];
        };
      };

    };
  };
}
