{ __findFile, ... }:
{
  den.hosts.x86_64-linux.sentinel = {
    users.sentinel.classes = [ "home-manager" ];
  };
  den.aspects.sentinel = {
    includes = [
      <den/define-user>
      <aegis/networking>
      <aegis/sops>
    ];

    nixos =
      { config, ... }:
      {
        imports = [ ./_disko.nix ];

        hardware.facter.reportPath = ./facter.json;

        sops.secrets.buttars-password.neededForUsers = true;

        users.mutableUsers = false;
        users.users.sentinel.hashedPasswordFile = config.sops.secrets.buttars-password.path;
        users.users.sentinel.extraGroups = [ "wheel" ];
        users.users.sentinel.openssh.authorizedKeys.keyFiles = [ ../../users/buttars/keys/id_ed25519.pub ];

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
