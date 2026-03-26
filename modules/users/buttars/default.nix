{ den, __findFile, ... }:
{
  den.aspects.buttars = {
    includes = [
      <den/primary-user>
      (den._.user-shell "fish")
      (<den/unfree> [ "claude-code" ])
      <aegis/programming>
      <aegis/terminal-emulator>
      <aegis/neovim>
      <aegis/cli>
      <aegis/cli/tui>
      <aegis/cli/git>
      <aegis/hyprland>
    ];

    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [ claude-code ];
      };
  };

  den.hosts.x86_64-linux.buttars-laptop.users.buttars.aspect = "buttars";
  den.hosts.x86_64-linux.buttars-desktop.users.buttars.aspect = "buttars";
}
