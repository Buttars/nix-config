{ pkgs, dotfiles, ... }:
let
  username = "portainer";
in
{
  hostConfig = {
    modules = {
      zsh.enable = true;
      docker.enable = true;
    };
    profiles = {
      portainer = {
        enable = true;
        pathToData = "/home/portainer/portainer/portainer/data/";
      };
    };
  };

  programs.nix-ld.enable = true;

  imports = [
    ../../../profiles/common.nix
    ../../../profiles/virtualization.nix
    ../../../profiles/server.nix
    ../../../profiles/portainer.nix
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "portainer";
    firewall.enable = false;
    interfaces = {
      ens18 = {
        ipv4.addresses = [
          {
            address = "10.0.1.2";
            prefixLength = 16;
          }
        ];
      };
    };
    defaultGateway = "10.0.0.1";
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
  };

  environment.systemPackages = with pkgs; [
    cargo
    nodejs
  ];

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  home-manager.users.${username} = { config, ... }: {
    home.stateVersion = "22.05";

    home.file.".config/nvim" = {
      source = "${dotfiles}/.config/nvim";
      recursive = true;
    };

    home.file.".config/tmux".source = "${dotfiles}/.config/tmux";
  };

  services.ntp.enable = true;
  services.automatic-timezoned.enable = true;
  services.openssh =
    {
      enable = true;
      passwordAuthentication = true;
    };

  system.stateVersion = "22.05";

  fileSystems = {
    "/home/portainer/portainer" = {
      device = "/dev/disk/by-label/portainer";
      fsType = "btrfs";
    };

    "/home/portainer/portainer/nextcloud" = {
      device = "/dev/disk/by-label/nextcloud-data";
      fsType = "btrfs";
    };

    "/var/lib/docker/volumes" = {
      depends = [ "/home/portainer/portainer" ];
      device = "/home/portainer/portainer/docker-volumes";
      fsType = "none";
      options = [ "bind" ];
    };
  };

}
