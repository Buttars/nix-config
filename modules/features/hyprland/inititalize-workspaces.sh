#!/bin/sh

# Wait a moment to ensure monitors are up (optional)
sleep 0.5

hyprctl -j monitors | jq -c '.[]' | while read -r monitor; do
  id=$(echo "$monitor" | jq '.id')
  name=$(echo "$monitor" | jq -r '.name')
  workspace="${id}1"

  hyprctl dispatch workspace "$workspace"
  hyprctl dispatch moveworkspacetomonitor "$workspace" "$name"
done

# Optionally focus a specific monitor (e.g., ID 1 if it exists)
hyprctl dispatch focusmonitor 1
