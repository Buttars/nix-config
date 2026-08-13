{ den, __findFile, ... }:
{
  den.aspects."landon.buttars" = {
    includes = [
      <den/primary-user>
      (<den/unfree> [ "obsidian" ])
      <aegix/programming>
      <aegix/terminal-emulator/kitty>
      <aegix/taskwarrior>
      <aegix/cli/git>
      <aegix/cli/tui>
      <aegix/neovim>
      <aegix/zsh>
      <aegix/zsh/prompt>
      <aegix/zsh/fzf-nav>
      <aegix/yazi>
      <aegix/workstation>
      <aegix/slack>
      <aegix/cloud>
      <aegix/toolsets/node>
      <aegix/toolsets/python>
      <aegix/github-mcp-server>
      <aegix/ai/kiro>
      <aegix/ai/claude>
      <aegix/ai/chatgpt>
      <aegix/ai/skills>
      <aegix/ai/omlx>
      <aegix/herdr>
      <aegix/cli/jj>
      <aegix/sops>
      <aegix/password-manager/bitwarden>
    ];
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.obsidian
          pkgs.anki-bin
          pkgs.parqeye
        ];
      };
  };
  den.hosts.aarch64-darwin.DRHCDGTHGJ.users."landon.buttars" = {
    classes = [ "homeManager" ];
    aspect = den.aspects."landon.buttars";
  };
}
