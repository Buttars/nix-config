{
  aegix.hyprland = {
    nixos = {
      programs.hyprland.enable = true;
      programs.dconf.enable = true;
    };

    homeManager =
      {
        config,
        pkgs,
        lib,
        inputs,
        ...
      }:
      {

        home.packages = with pkgs; [
          bibata-cursors
          font-awesome
          glib
          grim
          hyprlock
          hyprpaper
          hyprpicker
          jq
          libnotify
          nautilus
          rofi
          slurp
          swaynotificationcenter
          waybar
          waypaper
          wl-clipboard
          wlogout
          xdg-desktop-portal-hyprland
        ];

        wayland.windowManager.hyprland = {
          enable = true;
          configType = "lua";

          # TODO: Remove static monitor definition from aspect config
          settings = {
            monitor = lib.mkDefault [
              {
                output = "DP-3";
                mode = "3840x2160@60";
                position = "0x0";
                scale = 1;
              }
              {
                output = "DP-1";
                mode = "1920x1080@144";
                position = "3840x0";
                scale = 1;
              }
            ];
          };

          extraConfig = ''
            -- Environment
            hl.env("GDK_SCALE", "1")
            hl.env("QT_SCALE_FACTOR", "1")
            hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "0")
            hl.env("XCURSOR_SIZE", "20")
            hl.env("XCURSOR_THEME", "Bibata-Modern-Ice")
            hl.env("XDG_SESSION_TYPE", "wayland")
            hl.env("WLR_NO_HARDWARE_CURSORS", "1")

            -- Autostart (exec-once) + exec (cursor reapplied after reload)
            local function setup_cursor()
                hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 20")
                hl.exec_cmd("dconf write /org/gnome/desktop/interface/cursor-theme \"'Bibata-Modern-Ice'\"")
            end

            hl.on("hyprland.start", function()
                hl.exec_cmd("hyprpaper")
                hl.exec_cmd("swaync")
                hl.exec_cmd("waybar")
                hl.exec_cmd("xremap ~/.config/xremap/xremap.config")
                hl.exec_cmd("sh ~/.config/hypr/portal-launch.sh")
                hl.exec_cmd("sh ~/.config/hypr/initalize-workspaces.sh")
                setup_cursor()
            end)

            hl.on("config.reloaded", setup_cursor)

            -- Config
            hl.config({
                input = {
                    kb_layout     = "us",
                    kb_options    = "ctrl:nocaps",
                    follow_mouse  = 1,
                    sensitivity   = 0,
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
                    disable_splash_rendering  = true,
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
                xwayland = {
                    force_zero_scaling = true,
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

            -- Keybindings
            local mod = "SUPER"

            -- Launchers
            hl.bind(mod .. " + RETURN",            hl.dsp.exec_cmd("kitty"))
            hl.bind(mod .. " + W",                 hl.dsp.exec_cmd("$BROWSER"))
            hl.bind(mod .. " + SHIFT + W",         hl.dsp.exec_cmd("kitty -e sudo nmtui"))
            hl.bind(mod .. " + SHIFT + R",         hl.dsp.exec_cmd("kitty -e htop"))
            hl.bind(mod .. " + D",                 hl.dsp.exec_cmd("rofi -show drun & sleep 0.2; hyprctl dispatch focuswindow \"\\^(Rofi)\""))
            hl.bind(mod .. " + N",                 hl.dsp.exec_cmd("kitty -e nvim -c VimwikiIndex"))
            hl.bind(mod .. " + SHIFT + N",         hl.dsp.exec_cmd("kitty -e newsboat"))
            hl.bind(mod .. " + M",                 hl.dsp.exec_cmd("kitty -e ncmpcpp"))
            hl.bind(mod .. " + SHIFT + M",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
            hl.bind(mod .. " + Scroll_Lock",       hl.dsp.exec_cmd("killall screenkey || screenkey &"))
            hl.bind(mod .. " + SHIFT + S",         hl.dsp.exec_cmd("grim -g \"$(slurp -d)\" - | wl-copy"))
            hl.bind(mod .. " + CTRL + S",          hl.dsp.exec_cmd("grim -g \"$(slurp)\" ~/Pictures/screenshot-$(date +%s).png - | tee >(wl-copy) > /dev/null && notify-send 'Screenshot taken!'"))
            hl.bind(mod .. " + L",                 hl.dsp.exec_cmd("hyprlock"))
            hl.bind(mod .. " + SHIFT + L",         hl.dsp.exec_cmd("hyprlock & systemctl suspend"))
            hl.bind(mod .. " + CTRL + L",          hl.dsp.exec_cmd("hyprlock & systemctl hibernate"))
            hl.bind(mod .. " + Q",                 hl.dsp.window.close())
            hl.bind(mod .. " + SHIFT + BACKSPACE", hl.dsp.exit())

            -- Layout / Window control
            hl.bind(mod .. " + F",               hl.dsp.window.fullscreen({ mode = "fullscreen" }))
            hl.bind(mod .. " + SHIFT + F",       hl.dsp.window.fullscreen({ mode = "maximized" }))
            hl.bind(mod .. " + SHIFT + space",   hl.dsp.window.float({ action = "toggle" }))
            hl.bind(mod .. " + J",               hl.dsp.window.cycle_next({}))
            hl.bind(mod .. " + K",               hl.dsp.window.cycle_next({ next = false }))
            hl.bind(mod .. " + SHIFT + J",       hl.dsp.layout("swapnext"))
            hl.bind(mod .. " + SHIFT + K",       hl.dsp.layout("swapprev"))
            hl.bind(mod .. " + space",           hl.dsp.layout("swapwithmaster master"))
            hl.bind(mod .. " + A",               hl.dsp.layout("addmaster"))
            hl.bind(mod .. " + SHIFT + A",       hl.dsp.layout("removemaster"))
            hl.bind(mod .. " + Z",               hl.dsp.layout("setmasterfactor 0.05"))
            hl.bind(mod .. " + SHIFT + Z",       hl.dsp.layout("setmasterfactor -0.05"))
            hl.bind(mod .. " + O",               hl.dsp.layout("togglesplit"))
            hl.bind(mod .. " + T",               hl.dsp.layout("orientationleft"))
            hl.bind(mod .. " + B",               hl.dsp.layout("orientationbottom"))
            hl.bind(mod .. " + C",               hl.dsp.layout("orientationcenter"))

            -- Monitor navigation
            hl.bind(mod .. " + left",          hl.dsp.focus({ monitor = "-1" }),         { release = true })
            hl.bind(mod .. " + right",         hl.dsp.focus({ monitor = "+1" }),         { release = true })
            hl.bind(mod .. " + SHIFT + right", hl.dsp.window.move({ monitor = "+1" }),   { release = true })
            hl.bind(mod .. " + SHIFT + left",  hl.dsp.window.move({ monitor = "-1" }),   { release = true })

            -- Resize windows
            hl.bind(mod .. " + CTRL + H", hl.dsp.window.resize({ x = -100, y = 0,    relative = true }))
            hl.bind(mod .. " + CTRL + L", hl.dsp.window.resize({ x = 100,  y = 0,    relative = true }))
            hl.bind(mod .. " + CTRL + J", hl.dsp.window.resize({ x = 0,    y = 100,  relative = true }))
            hl.bind(mod .. " + CTRL + K", hl.dsp.window.resize({ x = 0,    y = -100, relative = true }))

            -- Workspace cycling
            hl.bind(mod .. " + Tab",       hl.dsp.focus({ workspace = "m+1" }))
            hl.bind(mod .. " + SHIFT + Tab", hl.dsp.focus({ workspace = "m-1" }))

            -- Scratchpad
            hl.bind(mod .. " + grave",         hl.dsp.workspace.toggle_special("term"))
            hl.bind(mod .. " + SHIFT + grave", hl.dsp.window.move({ workspace = "special:term" }))

            -- Volume & brightness
            hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
            hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
            hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true })
            hl.bind(mod .. " + plus",        hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
            hl.bind(mod .. " + minus",       hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
            hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set +10%"),                       { locked = true })
            hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 10%-"),                       { locked = true })

            -- Notification control
            hl.bind(mod .. " + SHIFT + C", hl.dsp.exec_cmd("makoctl dismiss -a"))

            -- Debug/dev tools
            hl.bind(mod .. " + SHIFT + X", hl.dsp.exec_cmd("kitty -e journalctl -f"))
            hl.bind(mod .. " + SHIFT + E", hl.dsp.exec_cmd("kitty -e nvim"))

            -- Workspace bindings (1-9)
            for i = 1, 9 do
                hl.bind(mod .. " + " .. i,         hl.dsp.focus({ workspace = i }))
                hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
            end

            -- Mouse binds
            hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
            hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

            -- Window rules
            hl.window_rule({
                match            = { class = "^(xwaylandvideobridge)$" },
                opacity          = "0.0 override 0.0 override",
                no_anim          = true,
                no_focus         = true,
                no_initial_focus = true,
            })

            for _, cls in ipairs({
                "^(Rofi)$",
                "^(org.gnome.Calculator)$",
                "^(org.gnome.Nautilus)$",
                "^(eww)$",
                "^(pavucontrol)$",
                "^(nm-connection-editor)$",
                "^(blueberry.py)$",
                "^(org.gnome.Settings)$",
                "^(org.gnome.design.Palette)$",
                "^(Color Picker)$",
                "^(Network)$",
                "^(xdg-desktop-portal)$",
                "^(xdg-desktop-portal-gnome)$",
                "^(transmission-gtk)$",
                "^(xdg-desktop-portal-gtk)$",
            }) do
                hl.window_rule({ match = { class = cls }, float = true })
            end
          '';
        };

        home.file = {
          ".config/hypr/audio-start.sh" = {
            source = ./audio-start.sh;
            executable = true;
          };

          ".config/hypr/portal-launch.sh" = {
            source = ./portal-launch.sh;
            executable = true;
          };

          ".config/hypr/initalize-workspaces.sh" = {
            source = ./inititalize-workspaces.sh;
            executable = true;
          };

          ".config/hypr/wallpaper.jpg".source = ./wallpaper.jpg;

          ".config/hypr/hyprpaper.conf".text = ''
            wallpaper {
                monitor = *
                path = ~/.config/hypr/wallpaper.jpg
            }
          '';
        };

      };
  };
}
