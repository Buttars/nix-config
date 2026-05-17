{ __findFile, ... }:
{
  den.aspects.buttars-desktop = {
    includes = [
      <den/define-user>
      <aegix/networking>
      <aegix/audio>
      <aegix/virtualization>
      <aegix/virtualization/docker>
      <aegix/nvidia>
      <aegix/sops>
      <aegix/fish>
      <aegix/hyprland>
      <aegix/fonts>
      <aegix/gaming>
      <aegix/zsa>
      <aegix/nfs-utils>
      <aegix/syncthing>
      # (<aegix/disks/btrfs> {
      #   disk = "/dev/sda";
      #   withSwap = true;
      #   swapSize = "32";
      # })
    ];

    nixos =
      { ... }:
      {
        hardware.enableRedistributableFirmware = true;

        boot.initrd.kernelModules = [ "amdgpu" ];
        boot.kernelModules = [ "kvm-intel" ];

        services.xserver.videoDrivers = [
          "amdgpu"
          "nvidia"
        ];

        nixpkgs.config.allowUnfree = true;

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
        };

        services.openssh.enable = true;
        services.syncthing.user = "buttars";
      };
  };

  flake-file.inputs.stylix.url = "github:nix-community/stylix";
  flake-file.inputs.stylix.inputs.nixpkgs.follows = "nixpkgs";
}
