# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{
  pkgs ? import <nixpkgs> { },
  ...
}:
{
  # example = pkgs.callPackage ./example { };
  sidecar = pkgs.callPackage ./sidecar.nix { };
  td = pkgs.callPackage ./td.nix { };
  specify-cli = pkgs.callPackage ./specify-cli.nix { };
  git-worktree-init = pkgs.callPackage ./git-worktree-init.nix { };
  truenas-mcp = pkgs.callPackage ./truenas-mcp.nix { };
}
