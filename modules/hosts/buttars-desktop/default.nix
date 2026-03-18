{ __findFile, inputs, ... }:
{
  den.hosts.x86_64-linux.buttars-desktop = {
    users.buttars-desktop.classes = [ "home-manager" ];
  };
  den.aspects.buttars-desktop = {
    includes = [
      <den/define-user>
      <aegis/networking>
      <aegis/audio>
      <aegis/virtualization>
      <aegis/nvidia>
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
        imports = [
          ./_disko.nix
          inputs.stylix.nixosModules.stylix
        ];
        environment.systemPackages = with pkgs; [ nfs-utils ];

        virtualisation.docker.daemon.settings = {
          storage-driver = "btrfs";
        };

        virtualisation.docker.enable = true;

        stylix.enable = true;
        stylix.autoEnable = false;
        stylix = {
          base16Scheme = builtins.fetchurl {
            url = "https://raw.githubusercontent.com/scottmckendry/cyberdream.nvim/main/extras/base16/cyberdream.yaml";
            sha256 = "1bfi479g7v5cz41d2s0lbjlqmfzaah68cj1065zzsqksx3n63znf";
          };
          override = {
            base00 = "#0F0F11";
            base0E = "#DE4F72";
          };
        };

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
