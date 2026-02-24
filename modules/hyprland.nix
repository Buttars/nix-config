{
  aegis.hyprland = {
    nixos = {
      nix.settings = {
        substituters = [ "https://hyprland.cachix.org" ];
        trusted-substituters = [ "https://hyprland.cachix.org" ];
        trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
      };
      environment.pathsToLink = [
        "/share/applications"
        "/share/xdg-desktop-portal"
      ];

      programs.hyprland.enable = true;
    };
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          bibata-cursors
        ];

        wayland.windowManager.hyprland = {
          enable = true;

          settings = {
            env = [
              "XCURSOR_THEME,Bibata-Modern-Ice"
              "XDG_SESSION_TYPE,wayland"
              "WLR_NO_HARDWARE_CURSORS,1"
            ];

            exec = [
              "hyprctl setcursor Bibata-Modern-Ice 20"
              "dconf write /org/gnome/desktop/interface/cursor-theme \"'Bibata-Modern-Ice'\""
            ];

            input = {
              kb_layout = "us";
              kb_options = "ctrl:nocaps";
              follow_mouse = 1;
              touchpad.natural_scroll = false;
              sensitivity = 0;
              accel_profile = "flat";
            };

            general = {
              gaps_in = 5;
              gaps_out = 20;
              border_size = 2;
              # col.active_border = "rgba(ffffffee)";
              # col.inactive_border = "rgba(595959aa)";
              layout = "master";
            };

            misc = {
              disable_hyprland_logo = true;
              on_focus_under_fullscreen = true;
            };

            decoration = {
              rounding = 10;
              blur = {
                enabled = true;
                size = 3;
                passes = 1;
              };
              shadow = {
                enabled = true;
                range = 4;
                render_power = 3;
                # color = "rgba(1a1a1aee)";
              };
            };

            animations = {
              enabled = true;
              bezier = "myBezier, 0.05, 0.9, 0.1, 1.0";
              animation = [
                "windows, 1, 3, default"
                "windowsOut, 1, 3, default"
                "border, 1, 3, default"
                "borderangle, 1, 3, default"
                "fade, 1, 3, default"
                "workspaces, 1, 3, default"
              ];
            };

            dwindle = {
              pseudotile = true;
              preserve_split = true;
            };

          };
        };
      };
  };
}
