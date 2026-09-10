{ inputs, ... }:
{
  # Rewrites flake.lock so every transitive input follows our own, rather than
  # pinning its author's. Smaller graph and one nixpkgs, at the cost of a
  # guaranteed cache miss for any input that publishes binaries built against
  # its own pin -- prefer such packages from nixpkgs over their flake input.
  imports = [ inputs.flake-file.flakeModules.nix-auto-follow ];
}
