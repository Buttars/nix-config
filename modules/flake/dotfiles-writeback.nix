{
  perSystem =
    { pkgs, ... }:
    {
      packages.dotfiles-writeback = pkgs.writeShellApplication {
        name = "dotfiles-writeback";
        runtimeInputs = [ pkgs.coreutils ];
        text = ''
          # Copy the live, hand-edited configs back into the repo before
          # turning dotfiles.mutable off again.
          repo="''${1:-$PWD}"
          if [ ! -d "$repo/modules/app" ]; then
            echo "not a nix-config checkout: $repo" >&2
            exit 1
          fi

          copy() {
            src="$HOME/.config/$1"
            dst="$repo/modules/app/$2"
            if [ -f "$src" ] && [ ! -L "$src" ]; then
              install -m644 "$src" "$dst"
              echo "  <- $1"
            fi
          }

          echo "writing back into $repo:"
          copy waybar/config.jsonc waybar/config.jsonc
          copy waybar/style.css waybar/style.css
          copy rofi/config.rasi rofi/config.rasi
          copy rofi/current.rasi rofi/current.rasi
          copy rofi/themes/rounded-common.rasi rofi/themes/rounded-common.rasi
          copy rofi/themes/rounded-gray-dark.rasi rofi/themes/rounded-gray-dark.rasi
          copy rofi/themes/rounded-nord-dark.rasi rofi/themes/rounded-nord-dark.rasi
          echo "done - now set dotfiles.mutable = false and rebuild"
        '';
      };
    };
}
