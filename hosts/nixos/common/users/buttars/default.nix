{
  inputs,
  pkgs,
  config,
  ...
}:
{
  users.users.buttars = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };

  openssh.authorizedKeys.keys = [
    (builtin.readFile ./keys/id_ed25519.pub)
  ];

  environment.systemPackages = [ pkgs.home-manager ];

  home-manager.extraSpecialArgs = {
    inherit inputs;
  };

  home-manager.users.buttars = import ../../../../../home/buttars/${config.networking.hostName}.nix;
}
