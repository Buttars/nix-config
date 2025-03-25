{ hostname, ... }:
{
  imports = [
    ../common/users/servus
    ../common/features/systemd-boot.nix
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = hostname;
    networkmanager.enable = true;
    firewall.enable = false;
  };

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";
}

