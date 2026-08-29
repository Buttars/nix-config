{
  # ncmpcpp is only a client; without a daemon serving ~/Music the keybind
  # opens to an error.
  aegix.mpd.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      home.packages = [ pkgs.ncmpcpp ];

      services.mpd = {
        enable = true;
        musicDirectory = "${config.home.homeDirectory}/Music";
      };
    };
}
