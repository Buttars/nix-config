{ __findFile, ... }:
{
  # A headless machine that exists to run services for other machines.
  #
  # Hardware, storage and the services themselves stay with the host; what is
  # here is only what is true of every server: reachable over ssh, observable,
  # and with its accounts declared rather than edited in place.
  aegix.server = {
    includes = [
      <aegix/server-baseline>
      <aegix/telemetry>
    ];

    nixos = {
      services.openssh.enable = true;

      # A server has no console to run passwd at, so the account set is whatever
      # this repo says it is. The password itself comes from the sops secret
      # rather than the store, which needs it staged before users are created.
      users.mutableUsers = false;
      sops.secrets.buttars-password.neededForUsers = true;
    };
  };
}
