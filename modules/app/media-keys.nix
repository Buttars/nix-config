{ ... }:
{
  # The XF86 media keys need these on PATH; without them the binds are dead.
  aegix.media-keys.homeManager =
    { lib, pkgs, ... }:
    lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      home.packages = with pkgs; [
        brightnessctl
        playerctl
      ];
      services.playerctld.enable = true;
    };
}
