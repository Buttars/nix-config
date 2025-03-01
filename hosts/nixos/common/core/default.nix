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

  programs.dconf.enable = true; # TODO: This will need to be moved once we create a non-desktop host.

  hardware.enableRedistributableFirmware = true;

}
