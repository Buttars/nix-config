let
  fontPackages =
    pkgs: with pkgs; [
      nerd-fonts.sauce-code-pro
      nerd-fonts.noto
      nerd-fonts.inconsolata
      nerd-fonts.roboto-mono
      nerd-fonts.commit-mono

      dejavu_fonts
      noto-fonts
      cantarell-fonts
      inter
      inter-nerdfont
      nebula-sans-nerdfont
    ];
in
{
  aegix.fonts = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-color-emoji

          font-manager
        ];

        fonts.packages = fontPackages pkgs;
      };

    homeManager =
      { pkgs, ... }:
      let
        fontDir = pkgs.runCommand "nix-fonts" { } ''
          mkdir -p $out
          ${builtins.concatStringsSep "\n" (
            map (pkg: ''
              find ${pkg}/share/fonts -name '*.ttf' -o -name '*.otf' -o -name '*.ttc' \
                | while read -r f; do
                    cp -n "$f" "$out/"
                  done
            '') (fontPackages pkgs)
          )}
        '';
      in
      {
        home.file."Library/Fonts/nix" = {
          source = fontDir;
          recursive = true;
        };
      };
  };
}
