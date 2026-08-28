{ inputs, den, ... }:
{
  _module.args.__findFile = den.lib.__findFile;
  imports = [
    inputs.den.flakeModule
    (inputs.den.namespace "aegix" true)
  ];

  flake-file.inputs.stylix.url = "github:nix-community/stylix";
  flake-file.inputs.stylix.inputs.nixpkgs.follows = "nixpkgs";
  flake-file.inputs.stylix.inputs.flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

  den.default.nixos.imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.disko.nixosModules.default
    inputs.stylix.nixosModules.stylix
  ];

}
