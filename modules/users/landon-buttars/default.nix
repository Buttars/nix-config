{ den, __findFile, ... }:
{
  den.aspects."landon.buttars" = {
    includes = [
      <den/primary-user>
      <aegis/features/programming>
      <aegis/features/terminal-emulator>
      <aegis/features/taskwarrior>
      <aegis/features/aws>
      <aegis/features/neovim>
      <aegis/features/cli>
      <aegis/features/git>
      {
        dotfiles.mutable = true;
      }
    ];
  };
  den.hosts.aarch64-darwin.DRHCDGTHGJ.users."landon.buttars".aspect = "landon.buttars";
}
