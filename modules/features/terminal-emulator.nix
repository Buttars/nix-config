{ aegix, ... }:
{
  aegix.terminal-emulator = {
    includes = [
      aegix.terminal-emulator._.kitty
    ];
    _.alacritty = {
      homeManager =
        { pkgs, ... }:
        {
          home.packages = [ pkgs.alacritty ];
        };
    };

    _.kitty = {
      homeManager =
        { ... }:
        {
          programs.kitty = {
            enable = true;

            font = {
              name = "CommitMono Nerd Font Mono";
              size = 11.0;
            };

            settings = {
              foreground = "#D9D7D6";
              background = "#0F0F11";
              color0 = "#0C141D";
              color1 = "#FF3377";
              color2 = "#40CF84";
              color3 = "#FFFF00";
              color4 = "#61D0FF";
              color5 = "#DE4F72";
              color6 = "#8EFBEE";
              color7 = "#D9D7D6";
              color8 = "#2E2E2E";
              color9 = "#FF6B8A";
              color10 = "#A3FF91";
              color11 = "#FFFF99";
              color12 = "#A3E4FF";
              color13 = "#BAA4D9";
              color14 = "#99E6FF";
              color15 = "#FFFFFF";
              bold_font = "auto";
              italic_font = "auto";
              scrollback_lines = 10000;
              scrollback_multiplier = 3;
              window_margin_width = "4 8";
              dynamic_background_padding = "no";
              enable_audio_bell = "no";
            };

            keybindings = {
              "alt+c" = "copy_to_clipboard";
              "alt+v" = "paste_from_clipboard";
              "kitty_mod+t" = "no_op";
            };
          };
        };
    };
  };
}
