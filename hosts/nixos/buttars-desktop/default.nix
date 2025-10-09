{ hostname, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../common/features/systemd-boot.nix
    ../common/features/zsa.nix
    ../common/features/syncthing.nix
    ../common/features/audio.nix
    ../common/features/virtualization.nix
    ../common/features/nvidia.nix
    ../common/features/fonts.nix
    ../common/features/gaming
    ../common/features/nfs-utils.nix
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
