#!/usr/bin/env bash
#  ┓ ┏┏┓┳┓┓┏┏┓┏┓┏┓┏┓┏┓  ┳┓┓┏┳┳┓
#  ┃╋┃┃┃┣┫┃┫┗┓┃┃┣┫┃ ┣   ┃┃┃┃┃┃
#  ┗┛┗┗┛┛┗┗┛┗┛┣┛┛┗┗┛┗┛  ┻┛┗┛┻┛┗┛
#
# Reassigns workspace rules for laptop-only mode (no external monitors).
# In docked mode the static rules in monitors.lua are already correct, so
# we exit early.

LG_CONNECTED=$(hyprctl monitors -j | jq '[.[].description] | map(contains("27GL650F")) | any | if . then 1 else 0 end')
DELL_CONNECTED=$(hyprctl monitors -j | jq '[.[].description] | map(contains("U2419HC")) | any | if . then 1 else 0 end')

if [ "$LG_CONNECTED" -eq 0 ] && [ "$DELL_CONNECTED" -eq 0 ]; then
    # Laptop-only: reassign all 10 workspaces to eDP-1
    hyprctl keyword workspace "1, monitor:eDP-1, default:true"
    for ws in 2 3 4 5 6 7 8 9 10; do
        hyprctl keyword workspace "$ws, monitor:eDP-1"
    done
    hyprctl dispatch workspace 1
fi
