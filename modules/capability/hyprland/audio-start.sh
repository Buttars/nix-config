#!/bin/sh

# kill if already running
killall -9 pipewire pipewire-pulse wireplumber

pipewire &
pipewire-pulse &
wireplumber &
