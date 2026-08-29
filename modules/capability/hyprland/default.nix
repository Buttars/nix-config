{ __findFile, ... }:
{
  aegix.hyprland = {
    includes = [
      <aegix/waybar>
      <aegix/rofi>
      <aegix/hyprlock>
      <aegix/hypridle>
      <aegix/polkit-agent>
      <aegix/cliphist>
      <aegix/satty>
      <aegix/swaync>
      <aegix/wallpaper>
      <aegix/media-keys>
      <aegix/wlogout>
    ];

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
      let
        sessionVars = config.home.sessionVariables;
        # vm-user does not set these, so only emit the ones present.
        sessionEnvNames = builtins.filter (n: sessionVars ? ${n}) [
          "BROWSER"
          "TERMINAL"
          "EDITOR"
        ];
        sessionEnvLines = lib.concatStringsSep "\n" (
          map (n: "            hl.env(\"${n}\", \"${sessionVars.${n}}\")") sessionEnvNames
        );
        # vm-user has no stylix, so fall back to literal cyberdream values.
        bare =
          name: fallback:
          if config.lib ? stylix then
            lib.removePrefix "#" config.lib.stylix.colors.withHashtag.${name}
          else
            fallback;
      in
      {

        # waybar and friends are started by systemd, not by Hyprland, so they
        # need the same variables independently of hl.env above.
        systemd.user.sessionVariables = lib.getAttrs sessionEnvNames sessionVars;

        home.packages = with pkgs; [
          bibata-cursors
          font-awesome
          glib
          grim
          hyprpaper
          hyprpicker
          jq
          libnotify
          nautilus
          slurp
          waypaper
          wl-clipboard
          xdg-desktop-portal-hyprland
          xremap
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

                        -- greetd starts the session without a login shell, so
                        -- home.sessionVariables are not inherited. Set the ones the
                        -- session itself uses; systemd.user.sessionVariables below covers
                        -- services like waybar, which systemd starts rather than Hyprland.
            ${sessionEnvLines}

                        -- Autostart (exec-once) + exec (cursor reapplied after reload)
                        local function setup_cursor()
                            hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 20")
                            hl.exec_cmd("dconf write /org/gnome/desktop/interface/cursor-theme \"'Bibata-Modern-Ice'\"")
                        end

                        hl.on("hyprland.start", function()
                            hl.exec_cmd("random-wallpaper")
                            hl.exec_cmd("xremap ~/.config/xremap/xremap.config")
                            hl.exec_cmd("sh ~/.config/hypr/portal-launch.sh")
                            setup_cursor()
                        end)

                        hl.on("config.reloaded", setup_cursor)

                        -- Config
                        hl.config({
                            input = {
                                kb_layout     = "us",
                                kb_options    = "ctrl:nocaps",
                                follow_mouse  = 0,
                                sensitivity   = 0,
                                accel_profile = "flat",
                                touchpad = {
                                    natural_scroll = false,
                                },
                            },
                            general = {
                                gaps_in     = 5,
                                gaps_out    = 12,
                                border_size = 3,
                                layout      = "scrolling",
                                ["col.active_border"] = {
                                    colors = { "rgba(${bare "base0D" "5ea1ff"}ff)", "rgba(${bare "base0C" "5ef1ff"}ff)" },
                                    angle  = 45,
                                },
                                ["col.inactive_border"] = {
                                    colors = { "rgba(${bare "base02" "3c4048"}ff)" },
                                },
                            },
                            scrolling = {
                                -- 0 = center, 1 = fit. fit aligns a column to the viewport
                                -- edge, which slams the window left on unfullscreen.
                                focus_fit_method = 0,
                            },
                            misc = {
                                disable_hyprland_logo     = true,
                                disable_splash_rendering  = true,
                                on_focus_under_fullscreen = true,
                            },
                            decoration = {
                                rounding = 0,
                                blur = {
                                    enabled = false,
                                },
                                shadow = {
                                    enabled      = true,
                                    range        = 8,
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

                        -- Animation curves. Speeds are deciseconds, so 2 = 200ms.
                        -- Kept short deliberately: motion should confirm what
                        -- happened, not delay it.
                        hl.curve("snap", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.0 } } })

                        hl.animation({ leaf = "windowsIn",   enabled = true, speed = 3, bezier = "snap", style = "popin 90%" })
                        hl.animation({ leaf = "windowsOut",  enabled = true, speed = 2, bezier = "snap", style = "popin 90%" })
                        hl.animation({ leaf = "windowsMove", enabled = true, speed = 2, bezier = "snap" })
                        hl.animation({ leaf = "border",      enabled = true, speed = 2, bezier = "snap" })
                        -- borderangle rotates the gradient continuously, which is
                        -- perpetual motion in the corner of your eye.
                        hl.animation({ leaf = "borderangle", enabled = false })
                        hl.animation({ leaf = "fade",        enabled = true, speed = 2, bezier = "snap" })
                        hl.animation({ leaf = "workspaces",  enabled = true, speed = 3, bezier = "snap", style = "slide" })

                        -- Keybindings
                        local mod = "SUPER"

                        -- Launchers
                        hl.bind(mod .. " + RETURN",            hl.dsp.exec_cmd("kitty"),                                                     { description = "Terminal" })
                        hl.bind(mod .. " + W",                 hl.dsp.exec_cmd("$BROWSER"),                                                  { description = "Browser" })
                        hl.bind(mod .. " + SHIFT + W",         hl.dsp.exec_cmd("kitty -e sudo nmtui"),                                       { description = "Network manager (nmtui)" })
                        hl.bind(mod .. " + SHIFT + R",         hl.dsp.exec_cmd("kitty -e htop"),                                             { description = "Process monitor (htop)" })
                        hl.bind(mod .. " + D",                 hl.dsp.exec_cmd("rofi -show drun"),                                           { description = "App launcher (rofi)" })
                        hl.bind(mod .. " + N",                 hl.dsp.exec_cmd("kitty -e nvim -c VimwikiIndex"),                             { description = "Notes (vimwiki)" })
                        hl.bind(mod .. " + SHIFT + N",         hl.dsp.exec_cmd("kitty -e newsboat"),                                         { description = "RSS reader (newsboat)" })
                        hl.bind(mod .. " + M",                 hl.dsp.exec_cmd("kitty -e ncmpcpp"),                                          { description = "Music player (ncmpcpp)" })
                        hl.bind(mod .. " + SHIFT + M",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),                { description = "Mute toggle" })
                        hl.bind(mod .. " + Scroll_Lock",       hl.dsp.exec_cmd("killall screenkey || screenkey &"),                          { description = "Screenkey toggle" })
                        hl.bind(mod .. " + SHIFT + S",         hl.dsp.exec_cmd("grim -g \"$(slurp -d)\" - | satty -f - --copy-command wl-copy --early-exit"), { description = "Screenshot region, annotate, copy" })
                        hl.bind(mod .. " + V",                 hl.dsp.exec_cmd("cliphist list | rofi -dmenu -i -p clipboard | cliphist decode | wl-copy"), { description = "Clipboard history" })
                        hl.bind(mod .. " + SHIFT + P",         hl.dsp.exec_cmd("random-wallpaper"),                                          { description = "Shuffle wallpaper" })
                        hl.bind(mod .. " + CTRL + S",          hl.dsp.exec_cmd("grim -g \"$(slurp)\" ~/Pictures/screenshot-$(date +%s).png - | tee >(wl-copy) > /dev/null && notify-send 'Screenshot taken!'"), { description = "Screenshot region to file" })
                        hl.bind(mod .. " + ALT + L",           hl.dsp.exec_cmd("hyprlock"),                                                  { description = "Lock screen" })
                        hl.bind(mod .. " + SHIFT + ALT + L",   hl.dsp.exec_cmd("hyprlock & systemctl suspend"),                              { description = "Lock and suspend" })
                        hl.bind(mod .. " + CTRL + ALT + L",    hl.dsp.exec_cmd("hyprlock & systemctl hibernate"),                            { description = "Lock and hibernate" })
                        hl.bind(mod .. " + Q",                 hl.dsp.window.close(),                                                        { description = "Close window" })
                        hl.bind(mod .. " + SHIFT + Q",         hl.dsp.exec_cmd("wlogout"),                                                   { description = "Power menu (wlogout)" })
                        hl.bind(mod .. " + SHIFT + BACKSPACE", hl.dsp.exit(),                                                                { description = "Exit Hyprland" })

                        -- Layout / Window control
                        -- internal = 2 (fullscreen) makes Hyprland fill the monitor as
                        -- usual; client = 0 (none) keeps the app from being told it's
                        -- fullscreen, so apps like Chrome don't switch into their own
                        -- fullscreen UI (hiding tabs/bookmarks bar).
                        hl.bind(mod .. " + F",               hl.dsp.window.fullscreen_state({ internal = 2, client = 0, action = "toggle" }), { description = "Fullscreen toggle" })
                        hl.bind(mod .. " + SHIFT + F",       hl.dsp.window.fullscreen({ mode = "maximized" }), { description = "Maximize toggle" })
                        hl.bind(mod .. " + SHIFT + space",   hl.dsp.window.float({ action = "toggle" }),       { description = "Float toggle" })
                        hl.bind(mod .. " + J",               hl.dsp.layout("focus d"),                         { description = "Focus window below" })
                        hl.bind(mod .. " + K",               hl.dsp.layout("focus u"),                         { description = "Focus window above" })
                        hl.bind(mod .. " + H",               hl.dsp.layout("focus l"),                         { description = "Focus column left" })
                        hl.bind(mod .. " + L",               hl.dsp.layout("focus r"),                         { description = "Focus column right" })
                        hl.bind(mod .. " + SHIFT + H",       hl.dsp.layout("swapcol l"),                       { description = "Move column left" })
                        hl.bind(mod .. " + SHIFT + L",       hl.dsp.layout("swapcol r"),                       { description = "Move column right" })
                        hl.bind(mod .. " + space",           hl.dsp.layout("promote"),                         { description = "Promote window to its own column" })
                        hl.bind(mod .. " + A",               hl.dsp.layout("consume"),                         { description = "Consume next column into this one (needs a column to the right)" })
                        hl.bind(mod .. " + SHIFT + A",       hl.dsp.layout("expel"),                           { description = "Expel window to its own column (needs a stacked column)" })
                        hl.bind(mod .. " + O",               hl.dsp.layout("fit expand"),                      { description = "Fit: expand column to free space" })
                        hl.bind(mod .. " + T",               hl.dsp.layout("fit toend"),                       { description = "Fit: active column to end of row" })
                        hl.bind(mod .. " + B",               hl.dsp.layout("fit tobeg"),                       { description = "Fit: start of row to active column" })
                        hl.bind(mod .. " + C",               hl.dsp.window.center(),                           { description = "Center window" })
                        hl.bind(mod .. " + SHIFT + C",       hl.dsp.layout("fit active"),                      { description = "Fit: active column fills screen" })

                        -- Monitor navigation
                        hl.bind(mod .. " + left",          hl.dsp.focus({ monitor = "-1" }),       { release = true, description = "Focus monitor left" })
                        hl.bind(mod .. " + right",         hl.dsp.focus({ monitor = "+1" }),       { release = true, description = "Focus monitor right" })
                        hl.bind(mod .. " + SHIFT + right", hl.dsp.window.move({ monitor = "+1" }), { release = true, description = "Move window to monitor right" })
                        hl.bind(mod .. " + SHIFT + left",  hl.dsp.window.move({ monitor = "-1" }), { release = true, description = "Move window to monitor left" })

                        -- Resize windows
                        hl.bind(mod .. " + comma",  hl.dsp.layout("colresize -0.05"), { description = "Column narrower" })
                        hl.bind(mod .. " + period", hl.dsp.layout("colresize +0.05"), { description = "Column wider" })
                        hl.bind(mod .. " + SHIFT + J", hl.dsp.window.resize({ x = 0, y = 100,  relative = true }), { description = "Window taller" })
                        hl.bind(mod .. " + SHIFT + K", hl.dsp.window.resize({ x = 0, y = -100, relative = true }), { description = "Window shorter" })

                        -- Workspace cycling
                        hl.bind(mod .. " + Tab",         hl.dsp.focus({ workspace = "m+1" }), { description = "Next workspace on this monitor" })
                        hl.bind(mod .. " + SHIFT + Tab", hl.dsp.focus({ workspace = "m-1" }), { description = "Previous workspace on this monitor" })

                        -- Scratchpad
                        hl.bind(mod .. " + grave",         hl.dsp.workspace.toggle_special("term"),             { description = "Scratchpad terminal toggle" })
                        hl.bind(mod .. " + SHIFT + grave", hl.dsp.window.move({ workspace = "special:term" }),  { description = "Move window to scratchpad" })

                        -- Volume & brightness
                        hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true, description = "Volume up" })
                        hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true, description = "Volume down" })
                        hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, description = "Mute toggle" })
                        hl.bind(mod .. " + plus",        hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true, description = "Volume up" })
                        hl.bind(mod .. " + minus",       hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true, description = "Volume down" })
                        hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set +10%"),                         { locked = true, description = "Brightness up" })
                        hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 10%-"),                         { locked = true, description = "Brightness down" })
                        hl.bind("XF86AudioPlay",         hl.dsp.exec_cmd("playerctl play-pause"),                          { locked = true, description = "Play / pause" })
                        hl.bind("XF86AudioNext",         hl.dsp.exec_cmd("playerctl next"),                                { locked = true, description = "Next track" })
                        hl.bind("XF86AudioPrev",         hl.dsp.exec_cmd("playerctl previous"),                            { locked = true, description = "Previous track" })
                        hl.bind("XF86AudioStop",         hl.dsp.exec_cmd("playerctl stop"),                                { locked = true, description = "Stop playback" })

                        -- Notification control
                        hl.bind(mod .. " + CTRL + C", hl.dsp.exec_cmd("swaync-client --close-all"), { description = "Dismiss all notifications" })

                        -- Cheatsheet
                        hl.bind(mod .. " + slash", hl.dsp.exec_cmd("sh ~/.config/hypr/keybinds.sh"), { description = "Show this keybind list" })

                        -- Debug/dev tools
                        hl.bind(mod .. " + SHIFT + X", hl.dsp.exec_cmd("kitty -e journalctl -f"), { description = "Follow system log" })
                        hl.bind(mod .. " + SHIFT + E", hl.dsp.exec_cmd("kitty -e nvim"),          { description = "Editor" })

                        -- Workspace bindings: workspace <monitor><slot>, where <monitor>
                        -- is the 1-based index of the monitor in left-to-right (x
                        -- position) order and <slot> is 0-9, e.g. 11 = monitor 1
                        -- workspace 1, 32 = monitor 3 workspace 2.
                        local function monitorsLeftToRight()
                            local mons = hl.get_monitors()
                            table.sort(mons, function(a, b) return a.x < b.x end)
                            return mons
                        end

                        local function monitorSlot(mon)
                            if mon == nil then
                                return 1
                            end
                            for i, m in ipairs(monitorsLeftToRight()) do
                                if m.id == mon.id then
                                    return i
                                end
                            end
                            return 1
                        end

                        local function monitorSignature(mons)
                            local names = {}
                            for _, mon in ipairs(mons) do
                                table.insert(names, mon.name)
                            end
                            return table.concat(names, ",")
                        end

                        local function applyWorkspaceRules(mons)
                            for _, mon in ipairs(mons) do
                                local slot = monitorSlot(mon)
                                for ws = 0, 9 do
                                    hl.workspace_rule({
                                        workspace  = tostring(slot * 10 + ws),
                                        monitor    = mon.name,
                                        default    = (ws == 1),
                                        persistent = (ws == 1),
                                    })
                                end
                            end
                        end

                        -- workspace_rule's `default` only takes effect when a monitor connects.
                        local function focusDefaultWorkspaces(mons)
                            for _, mon in ipairs(mons) do
                                hl.dispatch(hl.dsp.focus({ monitor = mon.name }))
                                hl.dispatch(hl.dsp.focus({ workspace = monitorSlot(mon) * 10 + 1 }))
                            end
                            if mons[1] ~= nil then
                                hl.dispatch(hl.dsp.focus({ monitor = mons[1].name }))
                            end
                        end

                        -- monitor.layout_changed fires continuously, not only on hotplug.
                        local lastMonitors = nil

                        local function pinWorkspacesToMonitors()
                            local mons = monitorsLeftToRight()
                            local signature = monitorSignature(mons)
                            if signature == lastMonitors then
                                return
                            end
                            lastMonitors = signature
                            applyWorkspaceRules(mons)
                            focusDefaultWorkspaces(mons)
                        end

                        pinWorkspacesToMonitors()
                        hl.on("monitor.layout_changed", pinWorkspacesToMonitors)

                        for d = 0, 9 do
                            hl.bind(mod .. " + " .. d, function()
                                local slot = monitorSlot(hl.get_active_monitor())
                                hl.dispatch(hl.dsp.focus({ workspace = slot * 10 + d }))
                            end, { description = "Go to workspace " .. d .. " on this monitor" })
                            hl.bind(mod .. " + SHIFT + " .. d, function()
                                local slot = monitorSlot(hl.get_active_monitor())
                                hl.dispatch(hl.dsp.window.move({ workspace = slot * 10 + d }))
                            end, { description = "Move window to workspace " .. d .. " on this monitor" })
                        end

                        -- Mouse binds
                        hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true, description = "Drag window" })
                        hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Resize window" })

                        -- Window rules
                        hl.window_rule({
                            match          = { class = ".*" },
                            suppress_event = "fullscreen",
                        })

                        hl.window_rule({
                            match            = { class = "^(xwaylandvideobridge)$" },
                            opacity          = "0.0 override 0.0 override",
                            no_anim          = true,
                            no_focus         = true,
                            no_initial_focus = true,
                        })

                        for _, cls in ipairs({
                            "^(termfilechooser)$",
                            "^(org.gnome.Calculator)$",
                            "^(org.gnome.Nautilus)$",
                            "^(eww)$",
                            "^(pavucontrol)$",
                            "^(nm-connection-editor)$",
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

                        -- rofi 2.x is a layer-shell surface, not a window, so
                        -- window rules never match it. Layer rules do.
                        hl.layer_rule({ match = { namespace = "^(rofi)$" }, animation = "popin 90%" })
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

          ".config/hypr/keybinds.sh" = {
            source = ./keybinds.sh;
            executable = true;
          };

          ".config/xremap/xremap.config".source = ./xremap.yaml;

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
