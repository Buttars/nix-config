{
  description = "A declarative NixOS configuration with Home Manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-wsl.url = "github:nix-community/nixos-wsl";

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:nix-community/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

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

    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      _module.args = {
        stateVersion = "25.05";
      };

      perSystem = { system, lib, ... }:
        let
          overlays = import ./overlays { inherit inputs; };
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [
              (inputs.darwin.overlays.default or (_: _: {}))
              overlays.additions
              overlays.modifications
              overlays.unstable-packages
            ];
          };
        in {
          _module.args.pkgs = pkgs;
          packages = import ./pkgs { inherit pkgs; };
          devShells = import ./shell.nix pkgs;
          formatter = pkgs.nixfmt-rfc-style;
        };

      flake = {
        overlays = import ./overlays { inherit inputs; };

        nixosModules = {
          home-manager = inputs.home-manager.nixosModules.home-manager;
          sops-nix    = inputs.sops-nix.nixosModules.sops;
          wsl         = inputs.nixos-wsl.nixosModules.default;
          disko       = inputs.disko.nixosModules.disko;
          stylix      = inputs.stylix.nixosModules.stylix;
        } 
        // nixpkgs.lib.mapAttrs'
            (name: _type: {
              name = nixpkgs.lib.removeSuffix ".nix" name;
              value = import (./modules + "/${name}");
            })
            (builtins.readDir ./modules);

        nixosModule = {
          imports = builtins.attrValues self.nixosModules;
        };

        nixosConfigurations =
          import ./hosts/nixos {
            inherit nixpkgs inputs;
            inherit (self) nixosModule;
            stateVersion = "25.05";
          };

        darwinConfigurations."N4FQ62JR4D" = inputs.darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = {
            inherit inputs;
            stateVersion = "25.05";
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
            ({ pkgs, ... }: {
              nixpkgs.overlays = [
                inputs.darwin.overlays.default
              ];
            })
          ];
        };
      };
    };
}
