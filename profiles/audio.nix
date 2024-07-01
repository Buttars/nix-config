{ config, pkgs, ... }: let
  cfg = config.hostConfig.modules;
in {
  imports = [];

  environment.systemPackages = with pkgs; [
    #pipewire
    pavucontrol
    pulsemixer
 ];

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    #wireplumber.enable = true;
    jack.enable = false;
  };

}
