{
  aegix.greeter.nixos = {
    # A greeter reads sessions from /share/wayland-sessions. hyprland ships
    # hyprland.desktop, but without this the path is never linked into the
    # system profile and the session list comes up empty.
    environment.pathsToLink = [ "/share/wayland-sessions" ];

    services.displayManager.regreet.enable = true;
    stylix.targets.regreet.enable = true;
  };
}
