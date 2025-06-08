{ config, pkgs, lib, inputs, ... }:
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
    nautilus
    rofi-wayland
    slurp
    swaynotificationcenter
    waybar
    waypaper
    wl-clipboard
    wlogout
    kdePackages.xwaylandvideobridge
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

      monitor = [
        "DP-3, 3840x2160@60, 0x0, 1"
        "DP-1, 1920x1080@144, 3840x0, 1"
      ];

      exec-once = [
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "swaync"
        "waybar"
        "xremap ~/.config/xremap/xremap.config"
        "xwaylandvideobridge"
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
        new_window_takes_over_fullscreen = 1;
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
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      gestures.workspace_swipe = false;


      "$mod" = "SUPER";
      bind = [
        "$mod, RETURN, exec, kitty"
        "$mod SHIFT, q, exec, sysact"
        "$mod, w, exec, exec $BROWSER"
        "$mod SHIFT, w, exec, kitty -e sudo nmtui"
        "$mod, e, exec, kitty -e neomutt"
        "$mod SHIFT, e, exec, kitty -e abook -C ~/.config/abook/abookrc --datafile ~/.config/abook/addressbook"
        "$mod, r, exec, kitty -e lfub"
        "$mod SHIFT, r, exec, kitty -e htop"
        "$mod, d, exec, rofi -show drun & sleep 0.2; hyprctl dispatch focuswindow \"\\^(Rofi)\""
        "$mod SHIFT, d, exec, passmenu"
        "$mod, c, exec, kitty -e profanity"
        "$mod, n, exec, kitty -e nvim -c VimwikiIndex"
        "$mod SHIFT, n, exec, kitty -e newsboat"
        "$mod, m, exec, kitty -e ncmpcpp"
        "$mod SHIFT, m, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        "$mod SHIFT, Print, exec, aimpick"
        "$mod, Scroll_Lock, exec, killall screenkey || screenkey &"
        "$mod SHIFT, s, exec, grim -g \"$(slurp -d)\" - | wl-copy"
        "$mod, l, exec, hyprlock"
        "$mod, q, killactive,"
        "$mod SUPER_SHIFT, BACKSPACE, exit"
        "$mod, f, fullscreenstate, 2 0"
        "$mod SHIFT, f, fullscreen, 1"
        "$mod SHIFT, space, togglefloating, 0"
        "$mod, j, cyclenext, next"
        "$mod, k, cyclenext, prev"
        "$mod SHIFT, j, layoutmsg, swapnext"
        "$mod SHIFT, k, layoutmsg, swapprev"
        "$mod, t, layoutmsg, orientationleft"
        "$mod SHIFT, t, layoutmsg, orientationbottom"
        "$mod, y, layoutmsg, orientationcenter"
        "$mod, space, layoutmsg, swapwithmaster master"
        "$mod SHIFT, left, execr, hyprctl dispatch focusmonitor -1"
        "$mod SHIFT, right, execr, hyprctl dispatch focusmonitor +1"
        "$mod, 1, execr, hyprctl dispatch workspace \"$activeMonitorId\"1"
        "$mod, 2, execr, hyprctl dispatch workspace \"$activeMonitorId\"2"
        "$mod, 3, execr, hyprctl dispatch workspace \"$activeMonitorId\"3"
        "$mod, 4, execr, hyprctl dispatch workspace \"$activeMonitorId\"4"
        "$mod, 5, execr, hyprctl dispatch workspace \"$activeMonitorId\"5"
        "$mod, 6, execr, hyprctl dispatch workspace \"$activeMonitorId\"6"
        "$mod, 7, execr, hyprctl dispatch workspace \"$activeMonitorId\"7"
        "$mod, 8, execr, hyprctl dispatch workspace \"$activeMonitorId\"8"
        "$mod, 9, execr, hyprctl dispatch workspace \"$activeMonitorId\"9"
        "$mod SHIFT, 1, execr, hyprctl dispatch movetoworkspace \"$activeMonitorId\"1"
        "$mod SHIFT, 2, execr, hyprctl dispatch movetoworkspace \"$activeMonitorId\"2"
        "$mod SHIFT, 3, execr, hyprctl dispatch movetoworkspace \"$activeMonitorId\"3"
        "$mod SHIFT, 4, execr, hyprctl dispatch movetoworkspace \"$activeMonitorId\"4"
        "$mod SHIFT, 5, execr, hyprctl dispatch movetoworkspace \"$activeMonitorId\"5"
        "$mod SHIFT, 6, execr, hyprctl dispatch movetoworkspace \"$activeMonitorId\"6"
        "$mod SHIFT, 7, execr, hyprctl dispatch movetoworkspace \"$activeMonitorId\"7"
        "$mod SHIFT, 8, execr, hyprctl dispatch movetoworkspace \"$activeMonitorId\"8"
        "$mod SHIFT, 9, execr, hyprctl dispatch movetoworkspace \"$activeMonitorId\"9"
        "$mod CTRL, right, execr, hyprctl dispatch movewindow mon:+1"
        "$mod CTRL, left, execr, hyprctl dispatch movewindow mon:-1"
        "$mod, right, resizeactive, 100 0"
        "$mod, left, resizeactive, -100 0"
        "$mod, down, resizeactive, 0 100"
        "$mod, up, resizeactive, 0 -100"
        "$mod, Tab, workspace, m+1"
        "$mod SHIFT, Tab, workspace, m-1"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      windowrulev2 = [
        "opacity 0.0 override 0.0 override,class:^(xwaylandvideobridge)$"
        "noanim,class:^(xwaylandvideobridge)$"
        "nofocus,class:^(xwaylandvideobridge)$"
        "noinitialfocus,class:^(xwaylandvideobridge)$"
        "float,class:^(Rofi)$"
        "float,class:^(org.gnome.Calculator)$"
        "float,class:^(org.gnome.Nautilus)$"
        "float,class:^(eww)$"
        "float,class:^(pavucontrol)$"
        "float,class:^(nm-connection-editor)$"
        "float,class:^(blueberry.py)$"
        "float,class:^(org.gnome.Settings)$"
        "float,class:^(org.gnome.design.Palette)$"
        "float,class:^(Color Picker)$"
        "float,class:^(Network)$"
        "float,class:^(xdg-desktop-portal)$"
        "float,class:^(xdg-desktop-portal-gnome)$"
        "float,class:^(transmission-gtk)$"
        "float,class:^(xdg-desktop-portal-gtk)$"
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

