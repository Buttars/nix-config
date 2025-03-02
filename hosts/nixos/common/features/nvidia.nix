{
  hardware.graphics = {
    enable = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    nvidiaSettings = true;
  };
}
