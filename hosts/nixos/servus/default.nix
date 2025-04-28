{ hostname, ... }: {

  imports = [
    ./hardware-configuration.nix
    ../common/users/servus
    ./nfs-mounts.nix
    ./virtualisation.nix
    ../common/services/home-assistant.nix
  ];

  home-assistant = {
    nfsAddress = "10.0.0.5";
    nfsExposedPath = "/mnt/veritas/cognito/services/home-assistant";
  };

  networking = {
    hostName = hostname;
    networkmanager.enable = true;
    firewall.enable = false;
    interfaces = {
      ens18 = {
        ipv4.addresses = [
          {
            address = "10.0.1.4";
            prefixLength = 16;
          }
        ];
      };
    };
    defaultGateway = "10.0.0.1";
    nameservers = [ "10.0.1.2" ];
  };

  services.openssh = {
    enable = true;
  };
}
