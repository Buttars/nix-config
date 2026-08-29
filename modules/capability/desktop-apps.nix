{
  # The small applications a full desktop ships: the ones other apps launch
  # by mimetype rather than ones you open by name.
  aegix.desktop-apps.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        gnome-calculator
        file-roller
        loupe
        papers
        networkmanagerapplet
      ];

      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "inode/directory" = "org.gnome.Nautilus.desktop";
          "application/pdf" = "org.gnome.Papers.desktop";
          "application/zip" = "org.gnome.FileRoller.desktop";
          "application/x-tar" = "org.gnome.FileRoller.desktop";
          "application/gzip" = "org.gnome.FileRoller.desktop";
          "image/png" = "org.gnome.Loupe.desktop";
          "image/jpeg" = "org.gnome.Loupe.desktop";
          "image/gif" = "org.gnome.Loupe.desktop";
          "image/webp" = "org.gnome.Loupe.desktop";
          "video/mp4" = "mpv.desktop";
          "video/x-matroska" = "mpv.desktop";
          "video/webm" = "mpv.desktop";
          "video/quicktime" = "mpv.desktop";
          "audio/mpeg" = "mpv.desktop";
          "audio/flac" = "mpv.desktop";
          "text/html" = "brave-browser.desktop";
          "x-scheme-handler/http" = "brave-browser.desktop";
          "x-scheme-handler/https" = "brave-browser.desktop";
        };
      };
    };
}
