{ ... }:
{
  # Managed as a service rather than a bare package so stylix themes the
  # notification popups and control centre.
  aegix.swaync.homeManager =
    { lib, pkgs, ... }:
    lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      services.swaync.enable = true;
    };
}
