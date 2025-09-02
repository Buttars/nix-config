{ pkgs, dotfiles, ... }:
{

  imports = [
    ../../common/core
    ../common/users/landon.buttars
    ../common/features/aerospace.nix
    ./system.nix
  ];

  environment.systemPackages = with pkgs; [
    nodejs
  ];

  nix.channel.enable = false;

  nix.settings.trusted-users = [
    "root"
    "landon.buttars"
    "@wheel"
  ];

  nix.gc.automatic = false;
  nix.optimise.automatic = false;

  nix.enable = false;

  system.primaryUser = "landon.buttars";

  # Used for backwards compatibility, please read the changelog before changing.
  system.stateVersion = 5;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;
}
