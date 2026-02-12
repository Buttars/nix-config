{
  aegis.features._.browser = {
    _.google-chrome.homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          google-chrome
        ];
      };
    _.brave.homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          brave
        ];
      };
  };
}
