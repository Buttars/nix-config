{ inputs, ... }:
let
  inherit (inputs) nixpkgs;
  lib = nixpkgs.lib.extend (_final: prev: import ../libs { lib = prev; });
  stateVersion = "25.11";
in
{
  imports = [
    inputs.devenv.flakeModule
  ];

  systems = nixpkgs.lib.systems.flakeExposed;

  flake = {
    overlays = import ../overlays { inherit inputs; };

    darwinConfigurations."DRHCDGTHGJ" = inputs.darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = {
        inherit inputs stateVersion lib;
        inherit (inputs) dotfiles;
      };
      modules = [
        ../hosts/darwin/DRHCDGTHGJ/configuration.nix
        inputs.home-manager.darwinModules.home-manager

        {
          home-manager.extraSpecialArgs = {
            inherit inputs stateVersion;
          };
          nixpkgs.overlays = [
            inputs.darwin.overlays.default
          ];
        }
      ];
    };

    nixosConfigurations = import ../hosts/nixos {
      inherit
        nixpkgs
        stateVersion
        inputs
        lib
        ;
    };
  };

  perSystem =
    { pkgs, ... }:
    {
      packages = pkgs.callPackage ../pkgs { };
      devenv.shells = import ../shell.nix { inherit pkgs; };
      formatter = pkgs.nixfmt-rfc-style;
    };
}
