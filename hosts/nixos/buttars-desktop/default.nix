{ hostname, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../../common/features/nixos/systemd-boot.nix
    ../../common/features/nixos/zsa.nix
    ../../common/features/nixos/syncthing.nix
    ../../common/features/nixos/audio.nix
    ../../common/features/nixos/virtualization.nix
    ../../common/features/nixos/nvidia.nix
    ../../common/features/nixos/fonts.nix
    ../../common/features/nixos/gaming
    ../../common/features/nixos/nfs-utils.nix
  ];

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
    hostName = hostname;
    networkmanager.enable = true;
    firewall.enable = false;
  };
}
