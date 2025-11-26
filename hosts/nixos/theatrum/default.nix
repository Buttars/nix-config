{
  pkgs,
  config,
  ...
}:
{

  imports = [
    ./hardware-configuration.nix

    ../servus/nfs-mounts.nix
    ../servus/virtualisation.nix

    ./jellyfin.nix
  ];

  networking = {
    networkmanager.enable = true;
    firewall.enable = false;
    interfaces = {
      ens18 = {
        ipv4.addresses = [
          {
            address = "10.0.1.5";
            prefixLength = 16;
          }
        ];
      };
    };
    defaultGateway = "10.0.0.1";
    nameservers = [ "10.0.1.2" ];
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    open = false;
  };

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      config.boot.kernelPackages.nvidiaPackages.stable
      nvidia-vaapi-driver
    ];
  };

  services.openssh = {
    enable = true;
  };
}
