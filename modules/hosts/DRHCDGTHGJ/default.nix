{ den, __findFile, ... }:
{
  den.hosts.aarch64-darwin.DRHCDGTHGJ = { };

  den.aspects.DRHCDGTHGJ = {
    includes = [
      <den/define-user>
      <aegix/networking>
      <aegix/aerospace>
    ];
  };
}
