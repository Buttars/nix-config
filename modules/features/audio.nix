# NOTE: I plan on migrating this functionality into aspects like desktop/workstation to better align with the aspects pattern.
{
  aegis.audio.nixos =
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
    };
}
