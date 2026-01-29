{ inputs, ... }:
{
  imports = [
    inputs.flake-file.flakeModules.default
  ];
  flake-file = {
    inputs = {
      flake-file.url = "github:vic/flake-file";
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
        # allRefs = true;
      };
    };
    nixConfig = { };
    description = "Your flake description";
  };
}
