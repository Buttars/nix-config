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
  # Decrypt buttars-password to /run/secrets-for-users/ so it can be used to create the user
  #sops.secrets.buttars-password.neededForUsers = true;
  #users.mutableUsers = false;

  users.users.buttars = {
    isNormalUser = true;
    #hashedPasswordFile = config.sops.secrets.buttars-password.path;
    shell = pkgs.fish;
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

  home-manager.users.buttars = import ../../../../../home/servus/${config.networking.hostName}.nix;
}
