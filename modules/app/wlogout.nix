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
        { "label": "hibernate","action": "hyprlock & systemctl hibernate", "text": "Hibernate","keybind": "h" }
        { "label": "logout",   "action": "hyprctl dispatch exit","text": "Log out", "keybind": "e" }
        { "label": "suspend",  "action": "hyprlock & systemctl suspend",   "text": "Suspend",  "keybind": "u" }
        { "label": "reboot",   "action": "systemctl reboot",    "text": "Reboot",   "keybind": "r" }
        { "label": "shutdown", "action": "systemctl poweroff",  "text": "Shutdown", "keybind": "s" }
      '';

      xdg.configFile."wlogout/style.css" = lib.mkIf (config.lib ? stylix) {
        text =
          let
            c = config.lib.stylix.colors.withHashtag;
            f = config.stylix.fonts;

            # wlogout is unwrapped, so gdk-pixbuf has no svg loader at runtime and
            # background-image silently fails. Rasterise here instead, recolouring
            # on the way: the assets ship with no fill and default to black.
            icons = pkgs.runCommand "wlogout-icons" { nativeBuildInputs = [ pkgs.librsvg ]; } ''
              mkdir -p $out/idle $out/active
              for svg in ${pkgs.wlogout}/share/wlogout/assets/*.svg; do
                name=$(basename "$svg" .svg)
                sed 's|<svg |<svg fill="${c.base05}" |' "$svg" \
                  | rsvg-convert -w 128 -h 128 -o "$out/idle/$name.png"
                sed 's|<svg |<svg fill="${c.base00}" |' "$svg" \
                  | rsvg-convert -w 128 -h 128 -o "$out/active/$name.png"
              done
            '';

            button = name: ''
              #${name} {
                background-image: url("${icons}/idle/${name}.png");
              }

              #${name}:hover,
              #${name}:focus {
                background-image: url("${icons}/active/${name}.png");
              }
            '';
          in
          ''
            * {
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
              border-radius: 0;
              margin: 8px;
              transition: background-color 150ms ease-in-out;
              background-repeat: no-repeat;
              background-position: center 35%;
              background-size: 22%;
              padding-top: 90px;
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

            ${lib.concatMapStrings button [
              "lock"
              "hibernate"
              "logout"
              "suspend"
              "reboot"
              "shutdown"
            ]}
          '';
      };
    };
}
