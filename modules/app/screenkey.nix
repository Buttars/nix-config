{
  # psmisc supplies killall, which the toggle keybind uses to stop a running
  # instance.
  aegix.screenkey.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        screenkey
        psmisc
      ];
    };
}
