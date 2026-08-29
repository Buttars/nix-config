{ ... }:
{
  aegix.wallpaper.homeManager =
    { config, pkgs, ... }:
    let
      # Wallpapers live outside the repo: they are large binaries, and one
      # 3.6MB image already exceeded jj's default new-file snapshot limit.
      dir = "${config.home.homeDirectory}/Pictures/wallpapers";
      fallback = "${config.home.homeDirectory}/.config/hypr/wallpaper.jpg";

      random-wallpaper = pkgs.writeShellApplication {
        name = "random-wallpaper";
        runtimeInputs = [
          pkgs.hyprpaper
          pkgs.coreutils
          pkgs.findutils
          pkgs.procps
        ];
        # hyprpaper's IPC rejects every request on this setup, so drive it by
        # writing a config and restarting it instead.
        text = ''
          dir="''${WALLPAPER_DIR:-${dir}}"

          pick=""
          if [ -d "$dir" ]; then
            pick=$(find "$dir" -type f \
              \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
              | shuf -n1)
          fi
          if [ -z "$pick" ]; then
            pick="${fallback}"
          fi
          [ -r "$pick" ] || exit 0

          conf="''${XDG_RUNTIME_DIR:-/tmp}/hyprpaper.conf"
          {
            printf 'splash = false\n'
            printf 'wallpaper {\n'
            printf '    monitor = *\n'
            printf '    path = %s\n' "$pick"
            printf '}\n'
          } > "$conf"

          pkill -x hyprpaper || true
          sleep 0.2
          hyprpaper -c "$conf" >/dev/null 2>&1 &
        '';
      };
    in
    {
      home.packages = [ random-wallpaper ];
      home.file."Pictures/wallpapers/.keep".text = "";
    };
}
