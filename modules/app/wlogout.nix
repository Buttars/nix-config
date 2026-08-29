{ ... }:
{
  # stylix has no wlogout target, so the palette is injected by hand from the
  # same source the other surfaces use.
  aegix.wlogout.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      home.packages = [ pkgs.wlogout ];

      xdg.configFile."wlogout/layout".text = ''
        { "label": "lock",     "action": "hyprlock",            "text": "Lock",     "keybind": "l" }
        { "label": "hibernate","action": "systemctl hibernate", "text": "Hibernate","keybind": "h" }
        { "label": "logout",   "action": "hyprctl dispatch exit","text": "Log out", "keybind": "e" }
        { "label": "suspend",  "action": "systemctl suspend",   "text": "Suspend",  "keybind": "u" }
        { "label": "reboot",   "action": "systemctl reboot",    "text": "Reboot",   "keybind": "r" }
        { "label": "shutdown", "action": "systemctl poweroff",  "text": "Shutdown", "keybind": "s" }
      '';

      xdg.configFile."wlogout/style.css" = lib.mkIf (config.lib ? stylix) {
        text =
          let
            c = config.lib.stylix.colors.withHashtag;
            f = config.stylix.fonts;
          in
          ''
            * {
              background-image: none;
              box-shadow: none;
              font-family: "${f.sansSerif.name}";
              font-size: ${toString f.sizes.popups}pt;
            }

            window {
              background-color: ${c.base00};
            }

            button {
              color: ${c.base05};
              background-color: ${c.base01};
              border: 2px solid ${c.base02};
              border-radius: 12px;
              margin: 8px;
              transition: background-color 150ms ease-in-out;
            }

            button:hover {
              background-color: ${c.base0D};
              color: ${c.base00};
              border-color: ${c.base0D};
            }

            button:focus {
              border-color: ${c.base0D};
            }

            #shutdown:hover,
            #reboot:hover {
              background-color: ${c.base08};
              border-color: ${c.base08};
            }
          '';
      };
    };
}
