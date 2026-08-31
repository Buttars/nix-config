{
  aegix.omniwm.homeManager =
    {
      pkgs,
      lib,
      ...
    }:
    lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      home.packages = [ pkgs.omniwm ];

      launchd.agents.omniwm = {
        enable = true;
        config = {
          Program = "${pkgs.omniwm}/Applications/OmniWM.app/Contents/MacOS/OmniWM";
          KeepAlive = true;
          RunAtLoad = true;
          StandardOutPath = "/tmp/omniwm.log";
          StandardErrorPath = "/tmp/omniwm.err.log";
        };
      };
    };
}
