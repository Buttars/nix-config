#!/bin/bash
# Toggle the scratchpad terminal, spawning it the first time.
# togglespecialworkspace on its own only shows and hides the workspace, so
# without this the scratchpad stays empty until a window is thrown into it.
set -eu

if hyprctl clients -j | jq -e 'any(.[]; .workspace.name == "special:term")' >/dev/null 2>&1; then
  hyprctl dispatch togglespecialworkspace term
else
  hyprctl dispatch exec '[workspace special:term silent] kitty --class scratchpad-term'
  hyprctl dispatch togglespecialworkspace term
fi
