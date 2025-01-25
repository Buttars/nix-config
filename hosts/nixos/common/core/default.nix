{ ... }:
{
  imports = [
    ./locale.nix
    ./nix-ld.nix
    ./nix.nix
    ./sops.nix
    ./fish.nix
  ];

  hardware.enableRedistributableFirmware = true;

}
