{ ... }:
{
  imports = [
    ./common/core
    ./common/features/cli
    ./common/features/desktop/common
    ./common/features/desktop/hyprland
    #./common/features/sops.nix
    ./common/features/desktop/common/browser.nix
    ./common/features/services/syncthing.nix
  ];
}
