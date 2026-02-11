{ den, __findFile, ... }:
{
  den.aspects."landon.buttars" = {
    includes = [
      <den/primary-user>
    ];
    homeManager = {
      imports = [
        <features/programming>
        <features/terminal-emulator>
        <features/taskwarrior>
        <features/aws>
        ./home.nix
      ];
    };
  };
  den.hosts.aarch64-darwin.DRHCDGTHGJ.users."landon.buttars".aspect = "landon.buttars";
}
