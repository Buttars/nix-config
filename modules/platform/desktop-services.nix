{
  # The services a desktop session assumes exist: removable media, trash,
  # network shares, thumbnails and power reporting.
  aegix.desktop-services.nixos = {
    services.gvfs.enable = true;
    services.udisks2.enable = true;
    services.tumbler.enable = true;
    services.upower.enable = true;
  };
}
