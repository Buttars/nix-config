{ hostname, ... }: {

  imports = [ ./hardware-configuration.nix ];

  networking = {
    hostName = hostname;
    networkmanager.enable = true;
    firewall.enable = true;
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
