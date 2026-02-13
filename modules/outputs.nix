{
  inputs,
  self,
  ...
}:
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

    nixosModules = {
      inherit (inputs.home-manager.nixosModules) home-manager;
      inherit (inputs.disko.nixosModules) disko;
      inherit (inputs.stylix.nixosModules) stylix;
      # xremap = inputs.xremap-flake.nixosModules.default;
      sops-nix = inputs.sops-nix.nixosModules.sops;
      wsl = inputs.nixos-wsl.nixosModules.default;
    };

    nixosModule = {
      imports = builtins.attrValues self.nixosModules;
    };

    nixosConfigurations = import ../hosts/nixos {
      inherit
        nixpkgs
        stateVersion
        inputs
        lib
        ;
      inherit (self) nixosModule;
    };
  };

  perSystem =
    { pkgs, ... }:
    {
      packages = import ../pkgs { inherit pkgs; };
      devenv.shells = import ../shell.nix { inherit pkgs; };
    };
}
