{ ... }:
{
  aegix.hyprlock.homeManager =
    { config, lib, ... }:
    let
      c =
        name: fallback:
        if config.lib ? stylix then config.lib.stylix.colors.withHashtag.${name} else fallback;
      rgb = name: fallback: "rgb(${lib.removePrefix "#" (c name fallback)})";
    in
    {
      programs.hyprlock = {
        enable = true;
        settings = {
          general = {
            hide_cursor = true;
            grace = 0;
          };

          background = [
            {
              path = "screenshot";
              blur_passes = 3;
              blur_size = 8;
              brightness = "0.6";
            }
          ];

          label = [
            {
              text = "$TIME";
              font_size = 92;
              font_family = "CommitMono Nerd Font Mono";
              color = rgb "base05" "#ffffff";
              position = "0, 200";
              halign = "center";
              valign = "center";
            }
            {
              text = "$USER";
              font_size = 16;
              font_family = "Inter Variable";
              color = rgb "base04" "#7b8496";
              position = "0, 100";
              halign = "center";
              valign = "center";
            }
          ];

          input-field = [
            {
              size = "300, 50";
              rounding = 12;
              outline_thickness = 2;
              dots_size = "0.25";
              dots_spacing = "0.3";
              outer_color = rgb "base0D" "#5ea1ff";
              inner_color = rgb "base01" "#1e2124";
              font_color = rgb "base05" "#ffffff";
              fail_color = rgb "base08" "#ff6e5e";
              check_color = rgb "base0B" "#5eff6c";
              placeholder_text = "";
              fail_text = "$FAIL";
              position = "0, -50";
              halign = "center";
              valign = "center";
            }
          ];
        };
      };
    };
}
