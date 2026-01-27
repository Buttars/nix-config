{ ... }:
{
  system.defaults.NSGlobalDomain = {
    InitialKeyRepeat = 15;
    KeyRepeat = 2;
    AppleShowAllExtensions = true;
    NSNavPanelExpandedStateForSaveMode = true;
    "com.apple.trackpad.enableSecondaryClick" = true;
    "com.apple.trackpad.trackpadCornerClickBehavior" = 1;
  };

  system.defaults.dock = {
    autohide = true;
    orientation = "bottom";
    showhidden = true;
    mru-spaces = false;
  };

  system.defaults.finder = {
    AppleShowAllExtensions = true;
    QuitMenuItem = true;
    FXEnableExtensionChangeWarning = false;
  };

  system.defaults.trackpad = {
    Clicking = true;
    TrackpadThreeFingerDrag = true;
    TrackpadRightClick = true;
  };

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };

  system.defaults.LaunchServices.LSQuarantine = false;

  # NOTE: This is preferred when using Aerospace window manager
  system.defaults.spaces.spans-displays = false;
}
