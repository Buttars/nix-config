{ inputs, den, ... }:
{
  _module.args.__findFile = den.lib.__findFile;
  imports = [
    (inputs.den.namespace "aegis" true)
    (inputs.den.namespace "features" false)
    (inputs.den.namespace "infra" false)
  ];
}
