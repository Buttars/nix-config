{ config, inputs, pkgs, ... }: {
  # NOTE: We may want to make this optional/configurable and place it in the modules instead.
  environment.systemPackages = [ pkgs.home-manager ];

  home-manager.extraSpecialArgs = { inherit inputs; };
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  # TODO: Make this configurable
  imports = [./buttars.nix];

}
