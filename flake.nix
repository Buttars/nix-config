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

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      stateVersion = "25.05";
    in
    {
      darwinConfigurations."N4FQ62JR4D" = inputs.darwin.lib.darwinSystem {
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
          stylex = inputs.stylix.nixosModules.stylix;
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

      packages = nixpkgs.lib.genAttrs inputs.flake-utils.lib.defaultSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };
        in
        import ./pkgs { inherit pkgs; }
      );

      # devShells = inputs.flake-utils.lib.eachDefaultSystem (
      #   system: import ./shell.nix nixpkgs.legacyPackages.${system}
      # );

      devShells = nixpkgs.lib.genAttrs inputs.flake-utils.lib.defaultSystems (system:
        (import ./shell.nix) nixpkgs.legacyPackages.${system}
      );

      overlays = import ./overlays { inherit inputs; };

      formatter = nixpkgs.lib.genAttrs inputs.flake-utils.lib.defaultSystems (system:
        nixpkgs.legacyPackages.${system}.nixfmt-rfc-style
      );

    };

}
