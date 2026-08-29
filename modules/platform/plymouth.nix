{
  aegix.plymouth.nixos = {
    boot.plymouth.enable = true;
    stylix.targets.plymouth.enable = true;

    # Without quieting the console the splash is interleaved with kernel log
    # spam, which defeats the point of having one.
    boot.kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];
  };
}
