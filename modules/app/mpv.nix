{
  aegix.mpv.homeManager =
    { ... }:
    {
      programs.mpv = {
        enable = true;
        config = {
          keep-open = "yes";
          save-position-on-quit = true;
          hwdec = "auto-safe";
          # Remember where playback stopped rather than restarting files.
          watch-later-options = "start,vid,aid,sid";
        };
      };
    };
}
