#!/bin/sh

sleep 0.5

hyprctl -j monitors | jq -c '.[]' | while read -r monitor; do
  id=$(echo "$monitor" | jq '.id')
  name=$(echo "$monitor" | jq -r '.name')
  prefix=$((id + 1))

  hyprctl dispatch focusmonitor "$name"
  for suffix in 3 2 1; do
    hyprctl dispatch workspace "${prefix}${suffix}"
  done
done

hyprctl dispatch focusmonitor 0
hyprctl dispatch workspace 11
