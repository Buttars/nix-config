{ ... }:
{
  hostConfig = {
    modules = {
      zsh.enable = true;
      docker.enable = true;
    };
  };

  programs.nix-ld.enable = true;

  imports = [
    ../../../profiles/common.nix
    ../../../profiles/virtualization.nix
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "veritas-portainer";
  };

  services.ntp.enable = true;
  services.automatic-timezoned.enable = true;

  system.stateVersion = "22.05";
}
