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
                bg0: ${c.base00};
                bg1: ${c.base01};
                bg2: ${c.base02};
                bg3: ${c.base0D};
                fg0: ${c.base05};
                fg1: ${c.base07};
                fg2: ${c.base04};
                fg3: ${c.base02};

                font: "${config.stylix.fonts.sansSerif.name} ${toString config.stylix.fonts.sizes.popups}";
              }
            '';
        };
      }
    ];
}
