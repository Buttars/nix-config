{ ... }:
{
  imports = [
    ./core
    ./features/cli
    ./features/shell/fish
    ./features/desktop
    ./features/desktop/hyprland
    ./features/sops.nix
    ./features/desktop/browser.nix
    ./features/services/syncthing.nix
  ];
}
