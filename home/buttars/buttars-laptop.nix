{ ... }:
{
  imports = [
    ./common/core
    ./common/features/cli
    ./common/features/shell/fish
    ./common/features/desktop/common
    ./common/features/desktop/hyprland
    #./common/features/sops.nix
    ./common/features/desktop/common/browser.nix
    ./common/features/services/syncthing.nix
  ];

  home.sessionVariables = {
    GDK_SCALE = ".7";
    GDK_DPI_SCALE = "0.5"; # Optional fine-tuning
    XCURSOR_SIZE = "20"; # Larger cursor to match scale
    OZONE_PLATFORM = "wayland";
  };

}
