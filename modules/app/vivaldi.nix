{
  aegix.vivaldi.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        vivaldi
      ];
    };
}
