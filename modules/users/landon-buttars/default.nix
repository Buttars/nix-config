{ den, __findFile, ... }:
{
  den.aspects."landon.buttars" = {
    includes = [
      <den/primary-user>
      <features/programming>
      <features/terminal-emulator>
      <features/taskwarrior>
      <features/aws>
    ];
    homeManager = {
      imports = [ ./home.nix ];
    };
  };
  den.hosts.aarch64-darwin.DRHCDGTHGJ.users."landon.buttars".aspect = "landon.buttars";
}
