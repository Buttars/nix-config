{ den, __findFile, ... }:
{
  den.aspects."landon.buttars" = {
    includes = [
      <den/primary-user>
      ./git.nix
    ];
    homeManager = {
      imports = [
        ../../../home/wgu/DRHCDGTHGJ.nix
      ];
    };
  };
  den.hosts.aarch64-darwin.DRHCDGTHGJ.users."landon.buttars".aspect = "landon.buttars";
}
