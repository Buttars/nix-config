{
  inputs,
  pkgs,
  config,
  ...
}:
{
  # Decrypt buttars-password to /run/secrets-for-users/ so it can be used to create the user
  sops.secrets.buttars-password.neededForUsers = true;
  users.mutableUsers = false;

  users.users.buttars = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets.buttars-password.path;
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];

    openssh.authorizedKeys.keys = [
      (builtins.readFile ./keys/id_ed25519.pub)
    ];
  };


  environment.systemPackages = [ pkgs.home-manager ];

  home-manager.extraSpecialArgs = {
    inherit inputs;
  };

  home-manager.users.buttars = import ../../../../../home/buttars/${config.networking.hostName}.nix;
}
