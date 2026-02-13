{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  hyprConfig = "${inputs.dotfiles}/.config/hypr";
in
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

    settings = {
      env = [
        "XCURSOR_SIZE,20"
        "XCURSOR_THEME,Bibata-Modern-Ice"
        "XDG_SESSION_TYPE,wayland"
        "WLR_NO_HARDWARE_CURSORS,1"
      ];

      monitor = lib.mkDefault [
        "DP-3, 3840x2160@60, 0x0, 1"
        "DP-1, 1920x1080@144, 3840x0, 1"
      ];

      exec-once = [
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "swaync"
        "waybar"
        "xremap ~/.config/xremap/xremap.config"
        "sh ~/.config/hypr/portal-launch.sh"
        "sh ~/.config/hypr/initalize-workspaces.sh"
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

      "$mod" = "SUPER";

      # TODO: Add colorpicker bindings

      bind = [
        # Launchers
        "$mod, RETURN, exec, kitty"
        "$mod, w, exec, exec $BROWSER"
        "$mod SHIFT, w, exec, kitty -e sudo nmtui"
        "$mod SHIFT, r, exec, kitty -e htop"
        "$mod, d, exec, rofi -show drun & sleep 0.2; hyprctl dispatch focuswindow \"\\^(Rofi)\""

        # "$mod SHIFT, d, exec, passmenu"
        # TODO: Update this to use keepasscli

        "$mod, n, exec, kitty -e nvim -c VimwikiIndex"
        # TODO: Fix Vimwiki command

        "$mod SHIFT, n, exec, kitty -e newsboat"
        # TODO: Add newsboat to installed packages

        "$mod, m, exec, kitty -e ncmpcpp"
        # TODO: Add ncmcpp to installed packages

        "$mod SHIFT, m, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"

        "$mod, Scroll_Lock, exec, killall screenkey || screenkey &"
        # TODO: Add screenkey to installed packages

        # TODO: Add more screenshot capabilities
        "$mod SHIFT, s, exec, grim -g \"$(slurp -d)\" - | wl-copy"
        "$mod CTRL, s, exec, grim -g \"$(slurp)\" ~/Pictures/screenshot-$(date +%s).png - | tee >(wl-copy) > /dev/null && notify-send 'Screenshot taken!'"

        "$mod, l, exec, hyprlock"
        # TODO: Reenable when suspend is fixed
        # "$mod SHIFT, l, exec, hyprlock && systemctl suspend"

        "$mod, q, killactive,"
        "$mod SUPER_SHIFT, BACKSPACE, exit"

        # Layout / Window control
        "$mod, f, fullscreenstate, 2 0"
        "$mod SHIFT, f, fullscreen, 1"
        "$mod SHIFT, space, togglefloating, 0"
        "$mod, j, cyclenext, next"
        "$mod, k, cyclenext, prev"
        "$mod SHIFT, j, layoutmsg, swapnext"
        "$mod SHIFT, k, layoutmsg, swapprev"
        "$mod, space, layoutmsg, swapwithmaster master"

        # TODO: Layout binds
        "$mod, a, layoutmsg, addmaster"
        "$mod SHIFT, a, layoutmsg, removemaster"

        "$mod, z, layoutmsg, setmasterfactor 0.05"
        "$mod SHIFT, z, layoutmsg, setmasterfactor -0.05"

        "$mod, o, layoutmsg, togglesplit"
        "$mod, t, layoutmsg, orientationleft"
        "$mod, b, layoutmsg, orientationbottom"
        "$mod, c, layoutmsg, orientationcenter"

        # Monitor navigation and movement
        "$mod, left, execr, hyprctl dispatch focusmonitor -1"
        "$mod, right, execr, hyprctl dispatch focusmonitor +1"
        "$mod SHIFT, right, execr, hyprctl dispatch movewindow mon:+1"
        "$mod SHIFT, left, execr, hyprctl dispatch movewindow mon:-1"

        # Resize windows
        "$mod CTRL, h, resizeactive, -100 0"
        "$mod CTRL, l, resizeactive, 100 0"
        "$mod CTRL, j, resizeactive, 0 100"
        "$mod CTRL, k, resizeactive, 0 -100"

        # Workspace cycling with fallback
        "$mod, Tab, exec, hyprctl dispatch workspace m+1 || hyprctl dispatch workspace 1"
        "$mod SHIFT, Tab, exec, hyprctl dispatch workspace m-1 || hyprctl dispatch workspace 9"

        # Scratchpad terminal
        "$mod, grave, togglespecialworkspace, term"
        "$mod SHIFT, grave, movetoworkspacesilent, special:term"

        # Volume & brightness
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86MonBrightnessUp, exec, brightnessctl set +10%"
        ", XF86MonBrightnessDown, exec, brightnessctl set 10%-"

        # Notification control
        "$mod, c, exec, makoctl dismiss"
        "$mod SHIFT, c, exec, makoctl dismiss -a"

        # Debug/dev tools
        "$mod SHIFT, x, exec, kitty -e journalctl -f"
        "$mod SHIFT, e, exec, kitty -e nvim"
      ]
      ++ (builtins.concatLists (
        builtins.genList (
          i:
          let
            ws = toString (i + 1);
            cmd = "hyprctl dispatch workspace \"$(hyprctl -j monitors | jq -r '.[] | select(.focused == true) | .id')${ws}\"";
            moveCmd = "hyprctl dispatch movetoworkspace \"$(hyprctl -j monitors | jq -r '.[] | select(.focused == true) | .id')${ws}\"";
          in
          [
            "$mod, ${ws}, execr, ${cmd}"
            "$mod SHIFT, ${ws}, execr, ${moveCmd}"
          ]
        ) 9
      ));

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      windowrule = [
        # xwaylandvideobridge
        "opacity 0.0 override 0.0 override, match:class ^(xwaylandvideobridge)$"
        "no_anim on, match:class ^(xwaylandvideobridge)$"
        "no_focus on, match:class ^(xwaylandvideobridge)$"
        "no_initial_focus on, match:class ^(xwaylandvideobridge)$"

        # Floating apps
        "float on, match:class ^(Rofi)$"
        "float on, match:class ^(org.gnome.Calculator)$"
        "float on, match:class ^(org.gnome.Nautilus)$"
        "float on, match:class ^(eww)$"
        "float on, match:class ^(pavucontrol)$"
        "float on, match:class ^(nm-connection-editor)$"
        "float on, match:class ^(blueberry.py)$"
        "float on, match:class ^(org.gnome.Settings)$"
        "float on, match:class ^(org.gnome.design.Palette)$"
        "float on, match:class ^(Color Picker)$"
        "float on, match:class ^(Network)$"
        "float on, match:class ^(xdg-desktop-portal)$"
        "float on, match:class ^(xdg-desktop-portal-gnome)$"
        "float on, match:class ^(transmission-gtk)$"
        "float on, match:class ^(xdg-desktop-portal-gtk)$"
      ];
    };
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [
        "~/.config/hypr/wallpaper.jpg"
      ];

      wallpaper = [
        ",~/.config/hypr/wallpaper.jpg"
      ];
    };
  };

  home.file = {
    ".config/hypr/audio-start.sh" = {
      source = "${hyprConfig}/audio-start.sh";
      executable = true;
    };

    ".config/hypr/portal-launch.sh" = {
      source = "${hyprConfig}/portal-launch.sh";
      executable = true;
    };

    ".config/hypr/initalize-workspaces.sh" = {
      source = "${hyprConfig}/inititalize-workspaces.sh";
      executable = true;
    };

    ".config/hypr/wallpaper.jpg".source = "${hyprConfig}/wallpaper.jpg";
  };
}
