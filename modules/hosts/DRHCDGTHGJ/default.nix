{ inputs, den, ... }:
{
  den.hosts.aarch64-darwin.DRHCDGTHGJ = {
    aspect = "DRHCDGTHGJ";
    hm-module = inputs.home-manager.darwinModules.home-manager;
  };
  den.aspects.DRHCDGTHGJ.darwin = {
    imports = [ ];
  };
}
