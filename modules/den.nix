{ inputs, den, ... }:
{
  _module.args.__findFile = den.lib.__findFile;
  imports = [
    inputs.den.flakeModule
    (inputs.den.namespace "aegis" true)
  ];

  den.default.nixos.imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.disko.nixosModules.default
    inputs.stylix.nixosModules.stylix
  ];

}
