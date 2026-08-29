#!/usr/bin/env bash
# Searchable list of the keybinds that carry a description, read live from the
# compositor. Lua binds report dispatcher "__lua" with an opaque registry index,
# so the description field is the only human-readable source.
set -euo pipefail

hyprctl binds -j |
  jq -r '
    def bit($m; $n): (($m / $n) | floor) % 2 == 1;
    def mods($m):
      [ if bit($m; 64) then "SUPER" else empty end
      , if bit($m; 4)  then "CTRL"  else empty end
      , if bit($m; 1)  then "SHIFT" else empty end
      , if bit($m; 8)  then "ALT"   else empty end
      ];
    [ .[] | select(.has_description) ]
    | map(((mods(.modmask) + [.key]) | join("+")) + "\t" + .description)
    | sort[]
  ' |
  awk -F'\t' '{ printf "%-26s %s\n", $1, $2 }' |
  rofi -dmenu -i -p keybinds >/dev/null
