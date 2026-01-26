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
    defaultGateway = "10.0.40.1";
    nameservers = [ "10.0.40.1" ];
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
