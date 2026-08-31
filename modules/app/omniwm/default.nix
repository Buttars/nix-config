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

      # OmniWM rewrites this file from its GUI (monitor routing, app rules, …),
      # so Nix owns it: `force` re-links the template on every switch. Mirror
      # any GUI change you want to keep back into settings.toml.
      xdg.configFile."omniwm/settings.toml" = {
        source = ./settings.toml;
        force = true;
      };
    };
}
