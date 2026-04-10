{ inputs, ... }:
{
  flake-file.inputs = {
    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";
    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";
  };

  imports = [
    (inputs.devenv.flakeModule or { })
  ];

  perSystem =
    { pkgs, ... }:
    {
      devenv.shells.default = {
        env.NIX_CONFIG = "extra-experimental-features = nix-command flakes ca-derivations";
        packages = with pkgs; [
          nix
          home-manager
          git
          just

          sops
          ssh-to-age
          gnupg
          age
        ];
      };
    };

  aegix.devenv = {
    homeManager =
      {
        pkgs,
        ...
      }:
      {
        programs.direnv = {
          enable = true;
          nix-direnv.enable = true;
        };

        home.packages = [ pkgs.devenv ];
      };
  };
}
