{
  description = "A declarative NixOS configuration with Home Manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";

    nixos-wsl.url = "github:nix-community/nixos-wsl";

    # xremap-flake.url = "github:xremap/nix-flake";

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    dotfiles = {
      url = "https://github.com/Buttars/.dotfiles";
      type = "git";
      ref = "main";
      submodules = true;
      flake = false;
    };
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      stateVersion = "24.11";
    in
    {
      darwinConfigurations."pro" = inputs.darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {
          inherit inputs;
          dotfiles = inputs.dotfiles;
        };
        modules = [
          ./hosts/darwin/N4FQ62JR/configuration.nix
          inputs.home-manager.darwinModules.home-manager
          (
            { config, pkgs, ... }:
            {
              nixpkgs.overlays = [
                inputs.darwin.overlays.default
                inputs.self.overlays.additions
                inputs.self.overlays.modifications
                inputs.self.overlays.unstable-packages
              ];
            }
          )
        ];
      };

      nixosModules =
        {
          home-manager = inputs.home-manager.nixosModules.home-manager;
          # xremap = inputs.xremap-flake.nixosModules.default;
          sops-nix = inputs.sops-nix.nixosModules.sops;
          wsl = inputs.nixos-wsl.nixosModules.default;
          disko = inputs.disko.nixosModules.disko;
        }
        // nixpkgs.lib.mapAttrs'
          (name: type: {
            name = nixpkgs.lib.removeSuffix ".nix" name;
            value = import (./modules + "/${name}");
          })
          (builtins.readDir ./modules);

      nixosModule = {
        imports = builtins.attrValues self.nixosModules;
      };

      nixosConfigurations = import ./hosts/nixos {
        inherit nixpkgs inputs stateVersion;
        nixosModule = self.nixosModule;
      };

      packages = inputs.flake-utils.lib.eachDefaultSystem (
        system: import ./pkgs nixpkgs.legacyPackages.${system}
      );

      # devShells = inputs.flake-utils.lib.eachDefaultSystem (
      #   system: import ./shell.nix nixpkgs.legacyPackages.${system}
      # );

      devShells.x86_64-linux = import ./shell.nix nixpkgs.legacyPackages.x86_64-linux;
      devShells.x86_64-darwin = import ./shell.nix nixpkgs.legacyPackages.x86_64-darwin;
      devShells.aarch64-darwin = import ./shell.nix nixpkgs.legacyPackages.aarch64-darwin;

      overlays = import ./overlays { inherit inputs; };

      # TODO: Figure out why flake-utils eachDefaultSystem does not return the expected an attribute set of systems.
      # formatter = inputs.flake-utils.lib.eachDefaultSystem (
      #   system: nixpkgs.legacyPackages."${system}".nixfmt-rfc-style
      # );

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
    };

}
