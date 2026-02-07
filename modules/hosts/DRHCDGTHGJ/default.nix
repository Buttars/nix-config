{ den, inputs, __findFile, ... }:
{
  den.hosts.aarch64-darwin.DRHCDGTHGJ = {
    aspect = "DRHCDGTHGJ";
  };
  den.aspects.DRHCDGTHGJ.darwin = { config, ... }: {
    imports = [
      {
        nix.enable = false;
      }
    ];
  };
}
