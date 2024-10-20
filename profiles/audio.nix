{ config, lib, pkgs, ... }:
let
  cfg = config.host.profiles.audio;
in
{
  options.host.profiles.audio = {
    enable = lib.mkEnableOption "Enable device audio";
  };

  config = lib.mkIf cfg.enable {
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
  };
}
