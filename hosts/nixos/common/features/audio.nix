{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    pavucontrol
    pulsemixer
    qpwgraph
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
