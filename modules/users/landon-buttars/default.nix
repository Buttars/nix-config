{ den, __findFile, ... }:
{
  den.aspects."landon.buttars" = {
    includes = [
      <den/primary-user>
      (<den/unfree> [ "obsidian" ])
      <aegix/programming>
      <aegix/kitty>
      <aegix/taskwarrior>
      <aegix/git>
      <aegix/cli/tui>
      <aegix/neovim>
      <aegix/zsh>
      <aegix/zsh/prompt>
      <aegix/zsh/fzf-nav>
      <aegix/yazi>
      <aegix/workstation>
      <aegix/omniwm>
      <aegix/theming>
      <aegix/cloud>
      <aegix/toolsets/node>
      <aegix/toolsets/python>
      <aegix/kiro>
      <aegix/skills>
      <aegix/omlx>
      <aegix/herdr>
      <aegix/jj>
      <aegix/sops>
      <aegix/bitwarden>
    ];
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.obsidian
          pkgs.anki-bin
          pkgs.parqeye
          pkgs.keymapp
          pkgs.slack
          pkgs.chatgpt
          pkgs.claude-code
          pkgs.github-mcp-server
          pkgs.mergiraf
        ];
        home.sessionVariables.HERDR_AGENT = "kiro-cli chat";
      };
  };
  den.hosts.aarch64-darwin.DRHCDGTHGJ.users."landon.buttars" = {
    classes = [ "homeManager" ];
    aspect = den.aspects."landon.buttars";
  };
}
