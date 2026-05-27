{ den, __findFile, ... }:
{
  den.aspects."landon.buttars" = {
    includes = [
      <den/primary-user>
      (<den/unfree> [ "obsidian" ])
      <aegix/programming>
      <aegix/terminal-emulator/kitty>
      <aegix/taskwarrior>
      <aegix/cli/aws>
      <aegix/cli/git>
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
      <aegix/slack>
      <aegix/toolsets/terraform>
      <aegix/toolsets/k8s>
      <aegix/toolsets/aws>
      <aegix/toolsets/node>
      <aegix/toolsets/python>
      <aegix/github-mcp-server>
      <aegix/ai/kiro>
      <aegix/ai/claude>
      <aegix/ai/chatgpt>
      <aegix/sops>
    ];
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.obsidian ];
      };
  };
  den.hosts.aarch64-darwin.DRHCDGTHGJ.users."landon.buttars" = {
    classes = [ "homeManager" ];
  };
}
