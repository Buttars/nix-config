{ den, __findFile, ... }:
{
  den.aspects."landon.buttars" = {
    includes = [
      <den/primary-user>
      <aegix/programming>
      <aegix/terminal-emulator/kitty>
      <aegix/taskwarrior>
      <aegix/cli/aws>
      <aegix/cli/tui>
      <aegix/neovim>
      <aegix/paneru>
      <aegix/tmux/full>
      <aegix/zsh>
      <aegix/zsh/prompt>
      <aegix/zsh/sesh>
      <aegix/zsh/fzf-nav>
      <aegix/yazi>
      <aegix/workstation>
    ];
  };
  den.hosts.aarch64-darwin.DRHCDGTHGJ.users."landon.buttars" = {
    aspect = "landon.buttars";
    classes = [ "homeManager" ];
  };
}
