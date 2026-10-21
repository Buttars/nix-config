{ inputs, lib, ... }:
{
  flake-file.inputs.den.url = lib.mkDefault "github:denful/den";
  imports = [
    (inputs.flake-file.flakeModules.dendritic or { })
    (inputs.den.flakeModules.dendritic or { })
  ];
}
