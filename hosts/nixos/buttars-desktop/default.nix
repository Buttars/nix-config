{ pkgs, hostname, ... }:
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
  stylix.autoEnable = true;
  # stylix = {
  #   base16Scheme = builtins.fetchurl {
  #     url = "https://raw.githubusercontent.com/scottmckendry/cyberdream.nvim/main/extras/base16/cyberdream.yaml";
  #     sha256 = "1bfi479g7v5cz41d2s0lbjlqmfzaah68cj1065zzsqksx3n63znf";
  #   };
  #   override = {
  #     base00 = "#0F0F11";
  #     base0E = "#DE4F72";
  #   };
  # };

  stylix.fonts = {
    sansSerif = {
      package = pkgs.inter-nerdfont;
      name = "Inter Nerd Font";
    };

    monospace = {
      package = pkgs.nerd-fonts.commit-mono;
      name = "CommitMono Nerd Font Mono";
    };
  };

  stylix.base16Scheme = {
    name = "Tokyo Neon Cyber";
    base00 = "0F0F11";
    base01 = "0C141D";
    base02 = "15161A";
    base03 = "2E2E2E";
    base04 = "A0A0A0";
    base05 = "D9D7D6";
    base06 = "E0DEDC";
    base07 = "A3FFFF";
    base08 = "FF3B7F";
    base09 = "FF9933";
    base0A = "FCEE0C";
    base0B = "19FF92";
    base0C = "19F9FF";
    base0D = "00F0FF";
    base0E = "FF2EA6";
    base0F = "FF6EC7";
  };

  # stylix.targets.hyprland.enable = true;

  programs.dconf.enable = true;

  programs.hyprland.enable = true;

  networking = {
    hostName = hostname;
    networkmanager.enable = true;
    firewall.enable = false;
  };
}
