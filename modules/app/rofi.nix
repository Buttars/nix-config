{ ... }:
{
  aegix.rofi.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    lib.mkMerge [
      (import ../lib/_mutable-files.nix { inherit config lib; } "rofi" {
        "rofi/config.rasi" = ./rofi/config.rasi;
        "rofi/current.rasi" = ./rofi/current.rasi;
        "rofi/themes/rounded-common.rasi" = ./rofi/themes/rounded-common.rasi;
        "rofi/themes/rounded-gray-dark.rasi" = ./rofi/themes/rounded-gray-dark.rasi;
        "rofi/themes/rounded-nord-dark.rasi" = ./rofi/themes/rounded-nord-dark.rasi;
      })
      {
        home.packages = [ pkgs.rofi ];

        xdg.configFile."rofi/colors.rasi" = lib.mkIf (config.lib ? stylix) {
          text =
            let
              c = config.lib.stylix.colors.withHashtag;
            in
            ''
              * {
                background:     ${c.base00};
                foreground:     ${c.base05};
                selected:       ${c.base0D};
                urgent:         ${c.base08};
                alternate-bg:   ${c.base01};
              }
            '';
        };
      }
    ];
}
