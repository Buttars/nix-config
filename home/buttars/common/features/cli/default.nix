{ ... }:
let
  common = toString ../../../../common;
in
{
  imports = [
    "${common}/features/cli/fish.nix"
    ./starship.nix
    ./git.nix
  ];

}
