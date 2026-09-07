{
  aegix.protonmail-bridge.homeManager =
    { lib, pkgs, ... }:
    lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      home.packages = with pkgs; [
        protonmail-bridge
      ];

      # The bridge stores its vault key through either a secret-service
      # implementation or pass, and refuses to accept an account without one.
      # pass is the only backend that needs no session daemon.
      programs.gpg.enable = true;
      programs.password-store.enable = true;

      services.gpg-agent = {
        enable = true;
        enableFishIntegration = true;
        pinentry.package = pkgs.pinentry-curses;
        defaultCacheTtl = 28800;
        maxCacheTtl = 86400;
      };

      systemd.user.services.protonmail-bridge = {
        Unit = {
          Description = "Proton Mail Bridge";
          After = [
            "network-online.target"
            "gpg-agent.service"
          ];
          Wants = [ "network-online.target" ];
        };
        Service = {
          ExecStart = "${pkgs.protonmail-bridge}/bin/protonmail-bridge --noninteractive";
          Restart = "on-failure";
          RestartSec = 5;
        };
        Install.WantedBy = [ "default.target" ];
      };
    };
}
