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
    ];

    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [ claude-code ];
      };
  };

  den.hosts.x86_64-linux.buttars-laptop.users.buttars.aspect = "buttars";
}
