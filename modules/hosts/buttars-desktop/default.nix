{ den, __findFile, ... }:
{
  den.hosts.x86_64-linux.buttars-desktop = {
    users.buttars = {
      classes = [ "homeManager" ];
      aspect = den.aspects.buttars;
    };
  };

  den.aspects.buttars-desktop = {
    includes = [
      <den/define-user>
      <aegix/networking>
      <aegix/audio>
      <aegix/virtualization>
      <aegix/docker>
      <aegix/nvidia>
      <aegix/sops>
      <aegix/fish>
      <aegix/hyprland>
      <aegix/desktop-services>
      <aegix/file-chooser>
      <aegix/greeter>
      <aegix/plymouth>
      <aegix/fonts>
      <aegix/gaming>
      <aegix/zsa>
      <aegix/syncthing>
      <aegix/reticulum>
      <aegix/ollama>
      <aegix/open-webui>
      # (<aegix/disks/btrfs> {
      #   disk = "/dev/sda";
      #   withSwap = true;
      #   swapSize = "32";
      # })
    ];

    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [ pkgs.nfs-utils ];

        hardware.enableRedistributableFirmware = true;

        boot.initrd.kernelModules = [ "amdgpu" ];
        boot.kernelModules = [ "kvm-intel" ];
        boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

        aegix.plymouth.disabledOutputs = [ "DP-3" ];

        environment.sessionVariables.AQ_DRM_DEVICES = "/dev/dri/by-path/pci-0000:01:00.0-card";

        services.xserver.videoDrivers = [
          "amdgpu"
          "nvidia"
        ];

        imports = [
          ./_disko.nix
          ./_stylix.nix
        ];

        virtualisation.docker.daemon.settings = {
          storage-driver = "btrfs";
        };

        networking = {
          networkmanager.enable = true;
          firewall.enable = false;
          nameservers = [ "10.0.20.1" ];
        };

        services.openssh.enable = true;
        services.syncthing.user = "buttars";

        home-manager.users.buttars = {
          aegix.hyprland.monitorMode = "static";
          aegix.hyprland.primaryMonitor = "DP-2";
          aegix.hypridle.autoSleep = false;

          wayland.windowManager.hyprland.settings = {
            monitor = [
              {
                output = "DP-3";
                mode = "3840x2160@60";
                position = "0x0";
                scale = 1;
              }
              {
                output = "DP-2";
                mode = "1920x1080@60";
                position = "3840x0";
                scale = 1;
              }
            ];
          };
        };
      };
  };

}
