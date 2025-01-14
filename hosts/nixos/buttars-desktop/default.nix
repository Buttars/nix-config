{ ... }: {
  imports = [
    ./hardware-configuration.nix

    ../common/core
    ../common/users/buttars

    ../common/optionals/systemd-boot.nix
    ../common/optionals/gamemode.nix
    ../common/optionals/zsa.nix
  ];

  networking = {
    hostName = "buttars-desktop";
    networkmanager.enable = true;
  };
}
