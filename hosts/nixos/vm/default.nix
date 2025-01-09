{ ... }:
{
  host = {
    modules = {
      hyprland.enable = false;
    };
  };


  imports = [
    ../common/optional/programming.nix
    ./users
  ];

  networking = {
    hostName = "nixos-vm";
    wireless.enable = false;
  };

  system.stateVersion = "24.05";
}
