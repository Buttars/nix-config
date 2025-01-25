{ ... }:
{
  imports = [
    ./common
    ./features/cli
    ./features/desktop/hyprland
    ./features/desktop/common/keepassxc.nix
    ./features/desktop/common/element-desktop.nix
  ];
}
