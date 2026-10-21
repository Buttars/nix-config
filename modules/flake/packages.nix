# Expose pkgs/ as flake package outputs, so `nix build .#<name>` works for
# first-party packages instead of only building them as part of a system.
#
# pkgs/ must be imported through the overlays, not a bare nixpkgs: the packages
# reference each other (gemma3-abliterated-gguf takes gguf-pad-vocab), and only
# `additions` makes siblings visible to callPackage.
{ inputs, config, ... }:
{
  perSystem =
    { system, lib, ... }:
    let
      overlays = [
        config.flake.overlays.additions
        config.flake.overlays.modifications
      ];

      pkgs = import inputs.nixpkgs {
        inherit system overlays;
        config.allowUnfree = true;
      };

      # pkgs/specify-cli.nix is a flake, not a callPackage function, so
      # pkgs.specify-cli cannot evaluate at all. Removed by name rather than
      # swallowed by a tryEval, so the breakage stays visible.
      candidates = removeAttrs (import ../../pkgs { inherit pkgs; }) [ "specify-cli" ];
    in
    {
      # Drop anything whose meta.platforms excludes this system (meshchat is
      # linux-only), so a darwin build does not fail on a package that was never
      # meant to be available here.
      packages = lib.filterAttrs (_: drv: lib.meta.availableOn pkgs.stdenv.hostPlatform drv) candidates;
    };
}
