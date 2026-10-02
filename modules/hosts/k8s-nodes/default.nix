{
  __findFile,
  lib,
  ...
}:
let
  # Interchangeable k3s agents on identical Proxmox VM specs, so one facter
  # report serves all of them. Each value is a nixos fragment applied to that
  # node alone -- empty until a node needs to differ.
  nodes = {
    k8s-1 = { };
    k8s-2 = { };
    k8s-3 = { };
  };
in
{
  den.hosts.x86_64-linux = lib.mapAttrs (name: _: {
    users.${name}.classes = [ "homeManager" ];
  }) nodes;

  den.aspects = lib.mapAttrs (name: override: {
    includes = [
      <den/define-user>
      <aegix/k3s-node>
    ];

    nixos =
      { config, ... }:
      {
        # Disko by path import, not via <aegix/disks/btrfs>: den applies this
        # aspect twice (once for the host, once for the same-named user), and
        # only identical import paths dedupe -- a function-call include yields
        # two anonymous modules and disko.devices collides with itself.
        imports = [ ./_disko.nix ];

        config = lib.mkMerge [
          {
            aegix.vector.endpoint = "http://sentinel.lan:9428/insert/loki/api/v1/push";

            hardware.facter.reportPath = ./facter.json;
            hardware.facter.detected.dhcp.interfaces = [ "ens18" ];

            users.users.${name} = {
              hashedPasswordFile = config.sops.secrets.buttars-password.path;
              extraGroups = [ "wheel" ];
              createHome = true;
              openssh.authorizedKeys.keyFiles = [ ../../users/buttars/keys/id_ed25519.pub ];
            };
            systemd.tmpfiles.rules = [ "d /home/${name}/.ssh 0700 ${name} users -" ];
          }
          override
        ];
      };

    homeManager = { };
  }) nodes;
}
