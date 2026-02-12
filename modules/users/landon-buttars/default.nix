{ den, __findFile, ... }:
{
  den.aspects."landon.buttars" = {
    includes = [
      <den/primary-user>
      <aegis/programming>
      <aegis/terminal-emulator>
      <aegis/taskwarrior>
      <aegis/cli>
      <aegis/cli/aws>
      <aegis/neovim>
      <aegis/git>
      {
        dotfiles.mutable = true;
      }
    ];
  };
  den.hosts.aarch64-darwin.DRHCDGTHGJ.users."landon.buttars".aspect = "landon.buttars";
}
