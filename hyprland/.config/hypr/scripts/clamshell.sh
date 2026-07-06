#!/usr/bin/env bash
#  ┏┓┓ ┏┓┳┳┓┏┓┓┏┏┓┓ ┓
#  ┃ ┃ ┣┫┃┃┃┗┓┣┫┣ ┃ ┃
#  ┗┛┗┛┛┗┛ ┗┗┛┛┗┗┛┗┛┗┛

LID_STATE="/proc/acpi/button/lid/LID0/state"

if grep -q closed "$LID_STATE"; then
    hyprctl keyword monitor "eDP-1, disable"
    # Workspace 10's home (eDP-1) is gone — park it on Dell
    hyprctl dispatch moveworkspacetomonitor 10 "desc:Dell Inc. DELL U2419HC"
else
    # Restore internal display at its explicit position in the layout
    hyprctl keyword monitor "eDP-1, 1920x1080@60, 3840x0, 1"
    # Return workspace 10 to its home monitor
    hyprctl dispatch moveworkspacetomonitor 10 eDP-1
fi
