{
  aegix.brave.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        brave
      ];
    };
}
