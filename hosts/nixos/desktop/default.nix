{ pkgs, ... }:
{
  host = {
    modules = {
      zsh.enable = true;
      docker.enable = true;
      steam.enable = true;
      nvidia.enable = true;
    };
    profiles = {
      audio.enable = true;
      desktop-theming.enable = true;
      hyprland.enable = true;
      password-management.enable = true;
      programming.enable = true;
      syncthing.enable = true;
      tui-file-manager.enable = true;
      tui-task-manager.enable = true;
      virtualization.enable = true;
      zsa.enable = true;
    };
    packages = with pkgs; [
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
  };

  services.udev.packages = [
    pkgs.android-udev-rules
  ];

  programs.nix-ld.enable = true;

  imports = [
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
