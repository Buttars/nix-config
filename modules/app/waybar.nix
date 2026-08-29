{ ... }:
{
  aegix.waybar.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    lib.mkMerge [
      (import ../lib/_mutable-files.nix { inherit config lib; } "waybar" {
        "waybar/config.jsonc" = ./waybar/config.jsonc;
        "waybar/style.css" = ./waybar/style.css;
      })
      {
        home.packages = [ pkgs.waybar ];

        # Palette only. style.css owns layout and imports this, so the theme
        # stays consistent while the design stays hand-editable.
        xdg.configFile."waybar/colors.css" = lib.mkIf (config.lib ? stylix) {
          text =
            let
              c = config.lib.stylix.colors.withHashtag;
            in
            ''
              @define-color background ${c.base00};
              @define-color foreground ${c.base05};
              @define-color accent     ${c.base0D};
              @define-color urgent     ${c.base08};
              @define-color warning    ${c.base0A};
              @define-color good       ${c.base0B};
            '';
        };

        systemd.user.services.waybar = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
          Unit = {
            Description = "Waybar";
            After = [ "graphical-session.target" ];
          };
          Service = {
            ExecStart = "${pkgs.waybar}/bin/waybar";
            ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR2 $MAINPID";
            Restart = "on-failure";
            RestartSec = 2;
          };
          Install.WantedBy = [ "default.target" ];
        };
      }
    ];
}
