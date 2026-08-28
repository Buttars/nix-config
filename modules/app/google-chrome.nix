{
  aegix.google-chrome.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        google-chrome
      ];
    };
}
