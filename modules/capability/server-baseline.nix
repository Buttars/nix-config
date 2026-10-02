{ __findFile, ... }:
{
  # What a machine needs before it can serve anything: a routed and firewalled
  # network stack, the ability to decrypt its own secrets, and a defence against
  # the brute-force traffic that follows an open port.
  aegix.server-baseline.includes = [
    <aegix/networking>
    <aegix/sops>
    <aegix/fail2ban>
  ];
}
