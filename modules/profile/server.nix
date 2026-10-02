{ __findFile, ... }:
{
  aegix.server = {
    includes = [
      <aegix/server-baseline>
      <aegix/telemetry>
    ];

    nixos = {
      services.openssh.enable = true;

      users.mutableUsers = false;
      # sops must stage this secret before users are created.
      sops.secrets.buttars-password.neededForUsers = true;
    };
  };
}
