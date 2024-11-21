{
  description = "A declarative NixOS configuration with Home Manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";

    nixos-wsl.url = "github:nix-community/nixos-wsl";

    xremap-flake.url = "github:xremap/nix-flake";

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    dotfiles = {
      flake = false;
      url = "https://github.com/Buttars/.dotfiles.git";
      type = "git";
    };
  };

  outputs = { self, nixpkgs, darwin, nixos-wsl, dotfiles, ... } @ inputs:
    let
      systems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;

      stateVersion = "24.04";
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
                inputs.self.overlays.additions
                inputs.self.overlays.modifications
                inputs.self.overlays.unstable-packages
              ];
            })
          ];
        };

      nixosModules =
        {
          home-manager = inputs.home-manager.nixosModules.home-manager;
          xremap = inputs.xremap-flake.nixosModules.default;
          sops-nix = inputs.sops-nix.nixosModules.sops;
          wsl = inputs.nixos-wsl.nixosModules.default;
          disko = inputs.disko.nixosModules.disko;
        } //
        nixpkgs.lib.mapAttrs'
          (name: type: {
            name = nixpkgs.lib.removeSuffix ".nix" name;
            value = import (./modules + "/${name}");
          })
          (builtins.readDir ./modules) //
        nixpkgs.lib.mapAttrs'
          (name: type: {
            name = nixpkgs.lib.removeSuffix ".nix" name;
            value = import (./profiles + "/${name}");
          })
          (builtins.readDir ./profiles);

      nixosModule = {
        imports = builtins.attrValues self.nixosModules;
      };

      nixosConfigurations = import ./hosts {
        inherit nixpkgs inputs stateVersion;
        nixosModule = self.nixosModule;
      };

      packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});

      overlays = import ./overlays { inherit inputs; };
    };

}

