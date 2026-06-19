{ inputs, lib, ... }:
{

  imports = [
    inputs.flake-file.flakeModules.nix-auto-follow
    inputs.treefmt-nix.flakeModule
  ];

  flake-file.inputs = {
    treefmt-nix.url = lib.mkDefault "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = lib.mkDefault "nixpkgs";
  };

  perSystem =
    { self', ... }:
    {
      packages.fmt = self'.formatter;

      devenv.shells.default.git-hooks.hooks = {
        treefmt = {
          enable = true;
          package = self'.formatter;
          settings.fail-on-change = false;
        };
        flake-check = {
          enable = true;
          name = "nix flake check";
          entry = "nix flake check --impure";
          pass_filenames = false;
          stages = [ "pre-push" ];
        };
      };

      treefmt = {
        projectRootFile = "flake.nix";
        programs = {
          nixfmt.enable = true;
          deadnix.enable = true;
          nixf-diagnose.enable = true;
          prettier.enable = true;
          shfmt.enable = true;
        };
        settings.on-unmatched = lib.mkDefault "fatal";
        settings.formatter.deadnix.options = lib.mkForce [
          "--edit"
          "--no-lambda-pattern-names"
        ];
        settings.formatter.nixf-diagnose.options = lib.mkForce [
          "--auto-fix"
          "--variable-lookup"
          "false"
        ];
        settings.global.excludes = [
          "dotfiles/*"
          "*/LICENSE"
          "*.{jpg,jpeg,png,gif,svg,ico,webp,woff,woff2,ttf,otf,pub}"
          "flake.lock"
          "*/flake.lock"
          ".envrc"
          ".direnv/*"
          ".devenv/*"
          "*/.gitignore"
          "modules/sops/secrets.yaml"
          "Justfile"
          "*.patch"
        ];
      };
    };

}
