{ __findFile, ... }:
{
  den.hosts.x86_64-linux.DRHCDGTHGJ = {
    users."landon.buttars".classes = [ "home-manager" ];
  };
  den.aspects.DRHCDGTHGJ = {
    includes = [
      <den/define-user>
      <aegis/networking>
    ];
  };
}
