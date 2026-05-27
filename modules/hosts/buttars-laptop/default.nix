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
          monitor = [ "eDP-1, 1920x1080@60, 0x0, 1" ];
          env = [
            "GDK_SCALE,1"
            "QT_SCALE_FACTOR,1"
            "QT_AUTO_SCREEN_SCALE_FACTOR,0"
          ];
          xwayland.force_zero_scaling = true;
        };
      };

    };
  };
}
