{ ... }: {
  imports = [
    ./locale.nix
    ./nix-ld.nix
    ./nix.nix
    ./sops.nix
  ];

  hardware.enableRedistributableFirmware = true;

}
