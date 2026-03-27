{
  __findFile,
  ...
}:
{
  den.hosts.x86_64-linux.torrens = { };
  den.aspects.torrens = {
    includes = [
      <den/define-user>
      <aegis/networking>
      <aegis/sops>
      (<aegis/disks/btrfs> {
        disk = "/dev/sda";
        withSwap = true;
        swapSize = "8";
      })
    ];

    nixos =
      { pkgs, ... }:
      {
        hardware.facter.reportPath = ./facter.json;
        hardware.facter.detected.dhcp.interfaces = [ "ens18" ];

        networking = {
          firewall = {
            enable = true;
            allowedTCPPorts = [ 22 ];
          };
        };

        services.openssh.enable = true;
        services.openssh.settings.PermitRootLogin = "yes";
        users.users.root.openssh.authorizedKeys.keyFiles = [
          ../../users/buttars/keys/id_ed25519.pub
        ];

        environment.systemPackages = [ pkgs.nfs-utils ];

        fileSystems."/srv" =
          let
            nfsProvider = "truenas.lan";
            nfsOptions = [
              "defaults"
              "noatime"
              "nfsvers=4.2"
              "rsize=262144"
              "wsize=262144"
              "nconnect=4"
              "async"
              "hard"
              "timeo=600"
              "retrans=2"
              "auto"
              "_netdev"
              "nofail"
            ];
          in
          {
            device = "${nfsProvider}:/mnt/veritas/cognito";
            fsType = "nfs";
            options = nfsOptions;
          };

        virtualisation.podman.enable = true;
      };

    homeManager = { };
  };
}
