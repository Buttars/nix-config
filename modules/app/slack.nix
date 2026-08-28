{
  aegix.slack.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        slack
      ];
    };
}
