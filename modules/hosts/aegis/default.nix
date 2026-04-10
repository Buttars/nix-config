{ __findFile, ... }:
{
  den.hosts.x86_64-linux.aegis = {
    users.aegis = {
      classes = [ "homeManager" ];
      aspect = "aegis-user";
    };
  };
  den.aspects.aegis = {
    includes = [
      <den/define-user>
      <aegix/networking>
      <aegix/sops>
    ];

    nixos =
      { config, ... }:
      {
        imports = [ ./_disko.nix ];

        hardware.facter.reportPath = ./facter.json;
        hardware.facter.detected.dhcp.interfaces = [ "ens18" ];

        sops.secrets.buttars-password.neededForUsers = true;

        users.mutableUsers = false;
        users.users.aegis.hashedPasswordFile = config.sops.secrets.buttars-password.path;
        users.users.aegis.extraGroups = [ "wheel" ];
        users.users.aegis.createHome = true;
        systemd.tmpfiles.rules = [
          "d /home/aegis/.ssh 0700 aegis users -"
        ];
        sops.secrets."private_keys/aegis" = {
          owner = "aegis";
          path = "/home/aegis/.ssh/id_ed25519";
          mode = "0600";
        };
        users.users.aegis.openssh.authorizedKeys.keyFiles = [ ../../users/buttars/keys/id_ed25519.pub ];

        services.openssh.enable = true;

        services.btrfs.autoScrub.enable = true;
        services.beesd.filesystems.nixroot = {
          spec = "/";
          hashTableSizeMB = 256;
          verbosity = "crit";
          extraOptions = [
            "--loadavg-target"
            "2.0"
          ];
        };
      };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.cowsay ];
      };
  };
}
