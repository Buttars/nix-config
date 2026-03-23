{ __findFile, ... }:
{
  den.hosts.aarch64-darwin.DRHCDGTHGJ = {
    users."landon.buttars".classes = [ "homeManager" ];
  };
  den.aspects.DRHCDGTHGJ = {
    includes = [
      <den/define-user>
      <aegis/networking>
    ];
  };
}
