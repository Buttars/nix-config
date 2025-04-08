{ pkgs, ... }:
{
  imports = [
    ./common/core
    ../common/features/programming.nix
    ../common/features/terminal-emulator.nix
    ../common/features/taskwarrior.nix
    ../common/features/cli/fish.nix
    ../common/features/aws.nix
  ];

  home.packages = with pkgs; [
    google-chrome
    firefox
  ];

}
