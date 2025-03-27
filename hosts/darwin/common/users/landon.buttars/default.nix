{ inputs, pkgs, lib, config, ... }:
let
  ifGroupsExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  users.users."landon.buttars" = {
    home = "/Users/landon.buttars/";
    # shell = pkgs.fish;
    # openssh.authorizedKeys.keys = [
    #   (builtins.readFile ./keys/id_ed25519.pub)
    # ];
  };

  environment.systemPackages = [ pkgs.home-manager ];

  home-manager.backupFileExtension = "backup";

  home-manager.extraSpecialArgs = {
    inherit inputs;
  };

  home-manager.useGlobalPkgs = true;

  home-manager.users."landon.buttars" = import ../../../../../home/wgu/N4FQ62JR4D.nix;
}
