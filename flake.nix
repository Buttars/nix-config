{
  description = "A declarative NixOS configuration with Home Manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-wsl.url = "github:nix-community/nixos-wsl";
    xremap-flake.url = "github:xremap/nix-flake";
  };

  outputs = { self, nixpkgs, home-manager, xremap-flake, nixos-wsl, ... } @ inputs: let
  in {
    nixosModules =
      {
        home-manager = home-manager.nixosModules.home-manager;
	xremap = xremap-flake.nixosModules.xremap;
      } //
      nixpkgs.lib.mapAttrs'
        (name: type: {
          name = nixpkgs.lib.removeSuffix ".nix" name;
          value = import (./modules + "/${name}");
        })
        (builtins.readDir ./modules);

    nixosModule = {
      imports = builtins.attrValues self.nixosModules;
    };

    nixosConfigurations = import ./hosts { inherit nixpkgs; nixosModule = self.nixosModule; inherit inputs; inherit nixos-wsl; };
  };
}

