{
  aegix.kitty = {
    homeManager =
      { ... }:
      {
        programs.kitty = {
          enable = true;

          settings = {
            macos_option_as_alt = "yes";
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
}
