#!/usr/bin/env bash
#  ┏┓┓ ┏┓┳┳┓┏┓┓┏┏┓┓ ┓
#  ┃ ┃ ┣┫┃┃┃┗┓┣┫┣ ┃ ┃
#  ┗┛┗┛┛┗┛ ┗┗┛┛┗┗┛┗┛┗┛

LID_STATE="/proc/acpi/button/lid/LID0/state"

if grep -q closed "$LID_STATE"; then
    hyprctl keyword monitor "eDP-1, disable"
    # Update workspace rule so Hyprland agrees ws10 now belongs to Dell
    hyprctl keyword workspace "10, monitor:desc:Dell Inc. DELL U2419HC"
    hyprctl dispatch moveworkspacetomonitor 10 "desc:Dell Inc. DELL U2419HC"
else
    # Restore internal display at its explicit position in the layout
    hyprctl keyword monitor "eDP-1, 1920x1080@60, 3840x0, 1"
    # Update workspace rule so Hyprland agrees ws10 belongs back to eDP-1
    hyprctl keyword workspace "10, monitor:eDP-1, default:true"
    hyprctl dispatch moveworkspacetomonitor 10 eDP-1
fi
