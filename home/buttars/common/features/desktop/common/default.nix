{ ... }:
{
  imports = [
    ./element-desktop.nix
    ./keepassxc.nix
    ./programming.nix
    ./terminal-emulator.nix
    ./discord.nix
    ./theming.nix
    ../../../../../common/features/xdg.nix
  ];
}
