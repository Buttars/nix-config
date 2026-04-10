{
  aegix.nvidia.nixos =
    { config, ... }:
    {
      hardware.graphics = {
        enable = true;
      };

      hardware.nvidia-container-toolkit.enable = true;

      hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = true;
        powerManagement.finegrained = false;
        nvidiaSettings = true;
        open = true;
        package = config.boot.kernelPackages.nvidiaPackages.production;
      };
    };
}
