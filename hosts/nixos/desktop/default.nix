{ ... }:
{
  host = {
    modules = {
      zsh.enable = true;
      alacritty.enable = false;
      brave.enable = true;
      discord.enable = true;
      obsidian.enable = true;
      docker.enable = true;
      steam.enable = true;
      vdhcoapp.enable = true;
      starship.enable = true;
      fastfetch.enable = true;
      xremap.enable = true;
      spr.enable = true;
      zoxide.enable = true;
      nvidia.enable = true;
    };

    profiles = {
      hyprland.enable = true;
      audio.enable = true;
      password-management.enable = true;
      programming.enable = true;
      syncthing.enable = true;
      tui-file-manager.enable = true;
      tui-task-manager.enable = true;
      virtualization.enable = true;
      zsa.enable = true;
    };
  };

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

  systemd.tmpfiles.rules = [ "f /dev/shm/looking-glass 0660 buttars kvm -" ];


  networking = {
    hostName = "buttars-desktop";
  };

  services.ntp.enable = true;
  services.automatic-timezoned.enable = true;

  system.stateVersion = "22.05";
}
