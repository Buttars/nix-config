{ inputs
, pkgs
, lib
, config
, ...
}:
let
  ifGroupsExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  users.users.servus = {
    isNormalUser = true;
    extraGroups = lib.flatten [
      "wheel"
      (ifGroupsExist [
        "networkmanager"
        "docker"
        "libvirtd"
        "postgres"
        "adbusers"
      ])
    ];

    openssh.authorizedKeys.keys = [
      (builtins.readFile ../buttars/keys/id_ed25519.pub)
    ];
  };

  environment.systemPackages = [ pkgs.home-manager ];

  home-manager.backupFileExtension = "backup";

  home-manager.extraSpecialArgs = {
    inherit inputs;
  };

  home-manager.useGlobalPkgs = true;

  # home-manager.users.servus = import ../../../../../home/servus/${config.networking.hostName}.nix;
}
