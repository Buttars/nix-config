{
  aegix.hyprland = {
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
          configType = "lua";

          extraConfig = ''
            -- Environment
            hl.env("XCURSOR_THEME", "Bibata-Modern-Ice")
            hl.env("XDG_SESSION_TYPE", "wayland")
            hl.env("WLR_NO_HARDWARE_CURSORS", "1")

            -- Cursor setup on start and reload
            local function setup_cursor()
                hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 20")
                hl.exec_cmd("dconf write /org/gnome/desktop/interface/cursor-theme \"'Bibata-Modern-Ice'\"")
            end

            hl.on("hyprland.start", setup_cursor)
            hl.on("config.reloaded", setup_cursor)

            -- Config
            hl.config({
                input = {
                    kb_layout    = "us",
                    kb_options   = "ctrl:nocaps",
                    follow_mouse = 1,
                    sensitivity  = 0,
                    accel_profile = "flat",
                    touchpad = {
                        natural_scroll = false,
                    },
                },
                general = {
                    gaps_in     = 5,
                    gaps_out    = 20,
                    border_size = 2,
                    layout      = "master",
                },
                misc = {
                    disable_hyprland_logo     = true,
                    on_focus_under_fullscreen = true,
                },
                decoration = {
                    rounding = 10,
                    blur = {
                        enabled = true,
                        size    = 3,
                        passes  = 1,
                    },
                    shadow = {
                        enabled      = true,
                        range        = 4,
                        render_power = 3,
                    },
                },
                animations = {
                    enabled = true,
                },
            })

            -- Animation curves
            hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.0 } } })
            hl.animation({ leaf = "windows",     enabled = true, speed = 3, bezier = "myBezier" })
            hl.animation({ leaf = "windowsOut",  enabled = true, speed = 3, bezier = "default"  })
            hl.animation({ leaf = "border",      enabled = true, speed = 3, bezier = "default"  })
            hl.animation({ leaf = "borderangle", enabled = true, speed = 3, bezier = "default"  })
            hl.animation({ leaf = "fade",        enabled = true, speed = 3, bezier = "default"  })
            hl.animation({ leaf = "workspaces",  enabled = true, speed = 3, bezier = "default"  })
          '';
        };
      };
  };
}
