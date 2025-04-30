{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    libsForQt5.qt5ct
    qt6ct
    nwg-look
  ];

  qt.enable = true;
  # qt.platformTheme.name = "gtk";
  # qt.style.name = "adwaita-dark";
  #
  gtk.enable = true;
  gtk.cursorTheme.package = pkgs.bibata-cursors;
  gtk.cursorTheme.name = "Bibata-Modern-Ice";

  # gtk.theme.package = pkgs.arc-theme;
  # gtk.theme.name = "Arc-Dark";

  gtk.iconTheme.package = pkgs.papirus-icon-theme;
  gtk.iconTheme.name = "Papirus-Dark";

  stylix.enable = true;
  # stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/rebecca.yaml";

  stylix.base16Scheme = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/scottmckendry/cyberdream.nvim/main/extras/base16/cyberdream.yaml";
    sha256 = "1bfi479g7v5cz41d2s0lbjlqmfzaah68cj1065zzsqksx3n63znf";
  };

  stylix.override = {
    base00 = "#0F0F11";
  };

  stylix.fonts = {
    serif = {
      package = pkgs.dejavu_fonts;
      name = "DejaVu Serif";
    };

    sansSerif = {
      package = pkgs.inter-nerdfont;
      name = "DejaVu Sans";
    };

    monospace = {
      package = pkgs.nerd-fonts.commit-mono;
      name = "DejaVu Sans Mono";
    };

    emoji = {
      package = pkgs.noto-fonts-emoji;
      name = "Noto Color Emoji";
    };

    sizes = {
      applications = 10;
      desktop = 10;
      popups = 10;
      terminal = 10;
    };

  };
}

