{ ... }: {
  imports = [
    ./hardware-configuration.nix

    ../common/core
    ../common/users/buttars
  ];

  networking = {
    hostName = "buttars-desktop";
    useDHCP = true;
    networkmanager.enable = true;
  };
}
