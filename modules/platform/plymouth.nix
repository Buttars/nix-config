{ ... }:
{
  aegix.plymouth.nixos =
    { config, lib, ... }:
    {
      options.aegix.plymouth.disabledOutputs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [ "DP-3" ];
        description = "Connectors to leave off during early boot, so the splash and any passphrase prompt land on the remaining one.";
      };

      config = {
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
        ]
        ++ map (o: "video=${o}:d") config.aegix.plymouth.disabledOutputs;
      };
    };
}
