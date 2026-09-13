{ ... }:
{
  aegix.keyd.nixos = {
    services.keyd = {
      enable = true;
      keyboards.default = {
        ids = [ "*" ];
        # Tap for escape, hold for super. keyd runs as a system service, so this
        # applies on the TTY and before login, not just inside the compositor.
        settings.main.capslock = "overload(meta, esc)";
      };
    };
  };
}
