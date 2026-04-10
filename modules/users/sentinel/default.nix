{ __findFile, ... }:
{
  den.aspects.sentinel-user = {
    includes = [
      <den/primary-user>
    ];

    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [ htop ];
      };
  };
}
