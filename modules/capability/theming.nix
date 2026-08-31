{
  aegix.theming.homeManager =
    { pkgs, lib, ... }:
    let
      isLinux = pkgs.stdenv.hostPlatform.isLinux;
    in
    {
      stylix.enable = true;
      stylix.image = ../capability/hyprland/wallpaper.jpg;

      stylix.base16Scheme = builtins.fetchurl {
        url = "https://raw.githubusercontent.com/scottmckendry/cyberdream.nvim/main/extras/base16/cyberdream.yaml";
        sha256 = "1bfi479g7v5cz41d2s0lbjlqmfzaah68cj1065zzsqksx3n63znf";
      };
      stylix.override = {
        base00 = "#0F0F11";
        base0E = "#DE4F72";
      };

      stylix.fonts = {
        serif = {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Serif";
        };

        sansSerif = {
          package = pkgs.inter-nerdfont;
          name = "Inter Variable";
        };

        monospace = {
          package = pkgs.nerd-fonts.commit-mono;
          name = "CommitMono Nerd Font Mono";
        };

        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };

        sizes = {
          applications = 10;
          desktop = 10;
          popups = 10;
          terminal = 10;
        };
      };

      stylix.targets = {
        kitty.enable = true;
        fish.enable = true;
        fzf.enable = true;
        yazi.enable = true;
        bat.enable = true;
        btop.enable = true;
        mpv.enable = true;

        gtk.enable = isLinux;
        qt.enable = isLinux;
        hyprland.enable = isLinux;
        # app/hyprlock.nix builds the full layout and reads the same palette,
        # so the stylix target would only conflict over `background`.
        hyprlock.enable = false;
        hyprpaper.enable = isLinux;
        swaync.enable = isLinux;
      };

      home.packages = lib.optionals isLinux (
        with pkgs;
        [
          libsForQt5.qt5ct
          qt6Packages.qt6ct
          nwg-look
        ]
      );

      qt.enable = isLinux;

      gtk = lib.mkIf isLinux {
        enable = true;
        cursorTheme.package = pkgs.bibata-cursors;
        cursorTheme.name = "Bibata-Modern-Ice";
        iconTheme.package = pkgs.papirus-icon-theme;
        iconTheme.name = "Papirus-Dark";
      };
    };
}
