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

    stylix.url = "github:danth/stylix";

    dotfiles = {
      url = "https://github.com/Buttars/.dotfiles";
      type = "git";
      ref = "main";
      rev = "94661c4849a6c340a1ca2f9b51506905326e3de5";
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
                inputs.self.overlays.additions
                inputs.self.overlays.modifications
                inputs.self.overlays.unstable-packages
              ];
            }
          )
        ];
      };

      nixosModules =
        [
          inputs.home-manager.nixosModules.home-manager
          # inputs.xremap-flake.nixosModules.default
          inputs.sops-nix.nixosModules.sops
          inputs.nixos-wsl.nixosModules.default
          inputs.disko.nixosModules.disko
          inputs.stylix.nixosModules.stylix
        ]
        // nixpkgs.lib.mapAttrs'
          (name: type: import (./modules + "/${name}"))
          (builtins.readDir ./modules)
        // {
          home-manager.extraSpecialArgs = { inherit inputs stateVersion; };
        };

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
