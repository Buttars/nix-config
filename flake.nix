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

    stylix.url = "github:nix-community/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs-awscli2.url = "github:nixos/nixpkgs/de74240d03acfd332c99dce42fc93239dcaa9cdf";

    dotfiles = {
      url = "https://github.com/Buttars/.dotfiles";
      type = "git";
      ref = "main";
      rev = "934e7a4df85550fef247b86211d5421144695e32";
      submodules = false;
      flake = false;
    };

    neovim-config = {
      url = "https://github.com/Buttars/kickstart-modular.nvim.git";
      type = "git";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    let
      systems = flake-utils.lib.defaultSystems;

      forEachSystem = f:
        nixpkgs.lib.genAttrs systems (system: f pkgsFor.${system});

      pkgsFor = nixpkgs.lib.genAttrs systems (system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        }
      );

      stateVersion = "25.05";
    in
    {
      darwinConfigurations."N4FQ62JR4D" = inputs.darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {
          inherit inputs stateVersion;
          dotfiles = inputs.dotfiles;
        };
        modules = [
          ./hosts/darwin/N4FQ62JR/configuration.nix
          inputs.home-manager.darwinModules.home-manager
          ({ inputs, stateVersion, ... }: {
            home-manager.extraSpecialArgs = {
              inherit inputs stateVersion;
            };
          })
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

      nixosModules =
        {
          home-manager = inputs.home-manager.nixosModules.home-manager;
          # xremap = inputs.xremap-flake.nixosModules.default;
          sops-nix = inputs.sops-nix.nixosModules.sops;
          wsl = inputs.nixos-wsl.nixosModules.default;
          disko = inputs.disko.nixosModules.disko;
          stylix = inputs.stylix.nixosModules.stylix;
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

      overlays = import ./overlays { inherit inputs; };

      packages = forEachSystem (pkgs:
        pkgs.callPackage ./pkgs { inherit pkgs; }
      );

      devShells = forEachSystem (pkgs:
        import ./shell.nix pkgs
      );

      formatter = nixpkgs.lib.genAttrs inputs.flake-utils.lib.defaultSystems (system:
        nixpkgs.legacyPackages.${system}.nixfmt-rfc-style
      );

    };

}
