{ __findFile, ... }:
{
  # Run unplugged: thermal and power-profile daemons to stretch the charge,
  # plus the warnings that stop it running out unannounced.
  aegix.battery.includes = [
    <aegix/power-management>
    <aegix/battery-notify>
  ];
}
