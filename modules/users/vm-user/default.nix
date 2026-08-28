{ den, __findFile, ... }:
{
  den.aspects.vm-user = {
    includes = [
      <den/primary-user>
      <aegix/devenv>
      <aegix/hyprland>
      (den._.user-shell "fish")
    ];

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.btop ];
      };
  };
}
