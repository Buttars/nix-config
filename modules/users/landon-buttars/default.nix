{ den, __findFile, ... }:
{
  den.aspects."landon.buttars" = {
    includes = [
      <den/primary-user>
      <aegis/programming>
      <aegis/terminal-emulator/kitty>
      <aegis/taskwarrior>
      <aegis/cli>
      <aegis/cli/aws>
      <aegis/cli/git>
      <aegis/cli/tui>
      <aegis/neovim>
      <aegis/paneru>
      <aegis/tmux/full>
      <aegis/zsh>
      <aegis/yazi>
      <aegis/workstation>
    ];
  };
  den.hosts.aarch64-darwin.DRHCDGTHGJ.users."landon.buttars" = {
    aspect = "landon.buttars";
    classes = [ "homeManager" ];
  };
}
