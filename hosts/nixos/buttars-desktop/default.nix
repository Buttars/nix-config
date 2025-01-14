{ ... }: {
  imports = [
    ./hardware-configuration.nix

    ../common/core
    ../common/users/buttars

    ../common/optionals/systemd-boot.nix
  ];

  networking = {
    hostName = "buttars-desktop";
    useDHCP = true;
    networkmanager.enable = true;
  };
}
