{
  description = "A declarative NixOS configuration with Home Manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";

    devenv.url = "github:cachix/devenv";

    nixos-wsl.url = "github:nix-community/nixos-wsl";

    # xremap-flake.url = "github:xremap/nix-flake";

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:nix-community/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs-awscli2.url = "github:nixos/nixpkgs/de74240d03acfd332c99dce42fc93239dcaa9cdf";

    dotfiles = {
      url = "https://github.com/Buttars/.dotfiles";
      type = "git";
      ref = "main";
      rev = "a52773c370f6837c666292e24adbbffe43a61de1";
      submodules = false;
      flake = false;
      allRefs = true;
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      {
        config,
        withSystem,
        moduleWithSystem,
        ...
      }:
      let
        stateVersion = "25.11";
      in
      {
        imports = [
          # Optional: use external flake logic, e.g.
          # inputs.foo.flakeModules.default
          inputs.devenv.flakeModule
        ];

        flake = {
          darwinConfigurations."DRHCDGTHGJ" = inputs.darwin.lib.darwinSystem {
            system = "aarch64-darwin";
            specialArgs = {
              inherit inputs stateVersion;
              inherit (inputs) dotfiles;
            };
            modules = [
              ./hosts/darwin/DRHCDGTHGJ/configuration.nix
              inputs.home-manager.darwinModules.home-manager
              (
                { inputs, stateVersion, ... }:
                {
                  home-manager.extraSpecialArgs = {
                    inherit inputs stateVersion;
                  };
                }
              )
              (
                { config, pkgs, ... }:
                {
                  nixpkgs.overlays = [
                    inputs.darwin.overlays.default
                  ];
                }
              )
            ];
          };

          nixosModules = {
            inherit (inputs.home-manager.nixosModules) home-manager;
            inherit (inputs.disko.nixosModules) disko;
            inherit (inputs.stylix.nixosModules) stylix;
            # xremap = inputs.xremap-flake.nixosModules.default;
            sops-nix = inputs.sops-nix.nixosModules.sops;
            wsl = inputs.nixos-wsl.nixosModules.default;
          }
          // nixpkgs.lib.mapAttrs' (name: type: {
            name = nixpkgs.lib.removeSuffix ".nix" name;
            value = import (./modules + "/${name}");
          }) (builtins.readDir ./modules);

          nixosModule = {
            imports = builtins.attrValues self.nixosModules;
          };

          nixosConfigurations = import ./hosts/nixos {
            inherit nixpkgs inputs stateVersion;
            inherit (self) nixosModule;
          };

          overlays = import ./overlays { inherit inputs; };
        };

        systems = nixpkgs.lib.systems.flakeExposed;

        perSystem =
          {
            system,
            config,
            pkgs,
            ...
          }:
          {
            packages = pkgs.callPackage ./pkgs { inherit pkgs; };
            devenv.shells = import ./shell.nix { inherit pkgs; };
            formatter = pkgs.nixfmt-rfc-style;
          };
      }
    );

}
