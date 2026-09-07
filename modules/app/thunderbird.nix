{
  aegix.thunderbird.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        thunderbird
      ];

      xdg.mimeApps.defaultApplications = {
        "x-scheme-handler/mailto" = "thunderbird.desktop";
        "message/rfc822" = "thunderbird.desktop";
      };
    };
}
