{ ... }:
{
  hostConfig = {
    modules = {
      hyprland.enable = true;
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
  };

  programs.nix-ld.enable = true;

  imports = [
    ../../../profiles/audio.nix
    ../../../profiles/programming.nix
    ../../../profiles/zsa.nix
    ../../../profiles/tui-file-manager.nix
    ../../../profiles/password-management.nix
    ../../../profiles/virtualization.nix
    ../../../profiles/tui-task-manager.nix
    ./users
    ./hardware-configuration.nix
  ];

  # TODO: Move this to a module.
  boot.initrd.kernelModules = [
    "vfio_pci"
    "vfio"
    "vfio_iommu_type1"

    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
  ];

  networking = {
    hostName = "buttars-desktop";
  };

  services.ntp.enable = true;
  services.automatic-timezoned.enable = true;

  system.stateVersion = "22.05";
}
