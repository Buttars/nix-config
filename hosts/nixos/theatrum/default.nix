{ hostname, config, ... }: {

  imports = [
    ./hardware-configuration.nix

    ../common/users/theatrum

    ../servus/nfs-mounts.nix
    ../servus/virtualisation.nix

    ./jellyfin.nix
  ];

  networking = {
    hostName = hostname;
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

  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  services.openssh = {
    enable = true;
  };
}
