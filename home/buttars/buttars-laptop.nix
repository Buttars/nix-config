{ ... }:
{
  imports = [
    ./common/core
    ./common/features/cli
    ./common/features/shell/fish
    ./common/features/desktop/common
    ./common/features/desktop/hyprland
    ./common/features/sops.nix
    ./common/features/desktop/common/browser.nix
    ./common/features/services/syncthing.nix
  ];

  home.sessionVariables = {
    GDK_SCALE = ".7";
    GDK_DPI_SCALE = "0.25"; # Optional fine-tuning
    XCURSOR_SIZE = "20"; # Larger cursor to match scale
    ELECTROL_OZONE_PLATFORM = "wayland";
  };

  wayland.windowManager.hyprland.settings.monitor = [
    "eDP-1, 1920x1080@60, 0x0, 1"
  ];
}
