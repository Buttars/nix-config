{ __findFile, ... }:
{
  aegix.server = {
    includes = [
      <aegix/server-baseline>
      <aegix/telemetry>
    ];

    nixos = {
      services.openssh.enable = true;
      services.openssh.settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "prohibit-password";
      };

      users.users.root.openssh.authorizedKeys.keyFiles = [
        ../users/buttars/keys/id_ed25519.pub
      ];

      security.sudo.wheelNeedsPassword = false;

      users.mutableUsers = false;
      # sops must stage this secret before users are created.
      sops.secrets.buttars-password.neededForUsers = true;
    };
  };
}
