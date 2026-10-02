{ __findFile, ... }:
{
  aegix.server-baseline.includes = [
    <aegix/networking>
    <aegix/sops>
    <aegix/fail2ban>
  ];
}
