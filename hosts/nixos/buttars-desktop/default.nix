{ pkgs, config, ... }:
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

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.hyprland}/bin/Hyprland --config /etc/greetd/hyprland.conf";
      };
    };
  };

  users.users.greeter = {
    isSystemUser = true;
    group = "greeter";
    shell = pkgs.bash;
  };

  users.groups.greeter = { };

  environment.etc."greetd/environments".text = ''
    Hyprland
  '';

  # TODO: Figure out how to configure the cursor to match the users home configuration.
  environment.etc."greetd/hyprland.conf".text =
    let
      hypr = config.programs.hyprland.package;
      bash = "${pkgs.bash}/bin/bash";
      gtkgreet = "${pkgs.gtkgreet}/bin/gtkgreet";
      hyprctl = "${hypr}/bin/hyprctl";
    in
    ''
      monitor = ,preferred,auto,auto

      env = XCURSOR_SIZE,20
      env = XCURSOR_THEME,Bibata-Modern-Ice
      env = XDG_SESSION_TYPE,wayland
      env = WLR_NO_HARDWARE_CURSORS,1

      exec-once = ${bash} -c '${gtkgreet} -l; ${hyprctl} dispatch exit'
    '';

  programs.dconf.enable = true;

  programs.hyprland.enable = true;

  networking = {
    networkmanager.enable = true;
    firewall.enable = false;
  };
}
