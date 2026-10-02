{ __findFile, ... }:
{
  # Make this machine one of my devices rather than a standalone box: the
  # shared folders follow it around and its outbound traffic leaves over the
  # VPN. Both are membership, not features of the desktop it happens to run.
  aegix.personal-network.includes = [
    <aegix/syncthing>
    <aegix/proton-vpn>
  ];
}
