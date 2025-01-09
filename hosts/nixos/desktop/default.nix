{ pkgs, ... }:
{
  host = {
    modules = {
      docker.enable = true;
      steam.enable = true;
      nvidia.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    alacritty
    brave
    discord-canary
    fastfetch
    obsidian
    spr
    vdhcoapp
    vesktop
    webcord
    zoxide
  ];

  programs.nix-ld.enable = true;

  services.udev.packages = [
    pkgs.android-udev-rules
  ];

  imports = [
    ../common/optional/audio.nix
    ../common/optional/desktop-theming.nix
    ../common/optional/hyprland.nix
    ../common/optional/password-management.nix
    ../common/optional/programming.nix
    ../common/optional/syncthing.nix
    ../common/optional/terminal-emulator.nix
    ../common/optional/tui-file-manager.nix
    ../common/optional/tui-task-manager.nix
    ../common/optional/virtualization.nix
    ../common/optional/zsa.nix
    ../common/optional/fish.nix
    ./users
    ./hardware-configuration.nix
  ];

  # TODO: Move this to a module.
  boot.initrd.kernelModules = [
    "vfio_pci"
    "vfio"
    "vfio_iommu_type1"
  ];

  boot.kernelParams = [
    "intel_iommu=on"
    "iommu=pt"
    "vfio-pci.ids=\"10de:2782,10de:22bc\""
  ];

  systemd.tmpfiles.rules = [
    "f /dev/shm/looking-glass 0660 buttars kvm -"
    "d /run/postgresql 0755 postgres postgres -"
    "d /var/lib/postgresql 0755 postgres postgres -"
  ];

  networking = {
    hostName = "buttars-desktop";
  };

  services.ntp.enable = true;
  services.automatic-timezoned.enable = true;

}
