{
  description = "A declarative NixOS configuration with Home Manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-wsl.url = "github:nix-community/nixos-wsl";
    xremap-flake.url = "github:xremap/nix-flake";
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    dotfiles = {
      flake = false;
      url = "https://github.com/Buttars/.dotfiles.git";
      type = "git";
    };
  };

  outputs = { self, nixpkgs, home-manager, darwin, xremap-flake, nixos-wsl, dotfiles, ... } @ inputs:
    let
      systems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;

      wsl = inputs.nixos-wsl;
      xremap = inputs.xremap-flake.nixosModules.default;
    in
    {
      darwinConfigurations."pro" = darwin.lib.darwinSystem
        {
          system = "x86_64-darwin";
          specialArgs = { inherit dotfiles; };
          modules = [
            ./hosts/darwin-x86/configuration.nix
            inputs.home-manager.darwinModules.home-manager
            ({ config, pkgs, ... }: {
              nixpkgs.overlays = [
                darwin.overlays.default
              ];
            })
          ];
        };

      nixosModules =
        {
          home-manager = home-manager.nixosModules.home-manager;
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

      nixosConfigurations = import ./hosts {
        inherit nixpkgs inputs wsl xremap home-manager;
        nixosModule = self.nixosModule;
      };

      packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});

      overlays = import ./overlays { inherit inputs; };
    };

}

