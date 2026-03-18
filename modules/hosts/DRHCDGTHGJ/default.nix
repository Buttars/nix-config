{ __findFile, ... }:
{
  den.hosts.aarch64-darwin.DRHCDGTHGJ = {
    users."landon.buttars".classes = [ "home-manager" ];
  };
  den.aspects.DRHCDGTHGJ = {
    includes = [
      <den/define-user>
      <aegis/networking>
    ];
  };
}
