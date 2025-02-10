{ ... }:
{
  imports = [
    ./locale.nix
    ./nix-ld.nix
    ./nix.nix
    #./sops.nix
    ./fish.nix
  ];

  services = {
    openssh.enable = true;
  };

  programs.ssh.startAgent = true;

  hardware.enableRedistributableFirmware = true;

}
