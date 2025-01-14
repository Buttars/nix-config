{ ... }: {
  imports = [
    ./hardware-configuration.nix

    ../common/core
    ../common/users/buttars

    ../common/optionals/systemd-boot.nix
    ../common/optionals/gamemode.nix
  ];

  networking = {
    hostName = "buttars-desktop";
    useDHCP = true;
    networkmanager.enable = true;
  };
}
