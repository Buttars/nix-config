{ __findFile, inputs, ... }:
{
  den.hosts.x86_64-linux.buttars-desktop = {
    users.buttars-desktop.classes = [ "homeManager" ];
  };
  den.aspects.buttars-desktop = {
    includes = [
      <den/define-user>
      <aegis/networking>
      <aegis/audio>
      <aegis/virtualization>
      <aegis/virtualization/docker>
      <aegis/nvidia>
      <aegis/sops>
      <aegis/fish>
      <aegis/browser/brave>
      <aegis/fonts>
      <aegis/gaming>
      <aegis/zsa>
      # (<aegis/disks/btrfs> {
      #   disk = "/dev/sda";
      #   withSwap = true;
      #   swapSize = "32";
      # })
    ];

    nixos =
      { pkgs, ... }:
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
        environment.systemPackages = with pkgs; [ nfs-utils ];

        virtualisation.docker.daemon.settings = {
          storage-driver = "btrfs";
        };

        virtualisation.docker.enable = true;

        programs.dconf.enable = true;

        programs.hyprland.enable = true;

        networking = {
          networkmanager.enable = true;
          firewall.enable = false;
        };

        services.openssh.enable = true;
      };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.cowsay ];
      };
  };

  flake-file.inputs.stylix.url = "github:nix-community/stylix";
  flake-file.inputs.stylix.inputs.nixpkgs.follows = "nixpkgs";
}
