#!/usr/bin/env bash
#  ┏┓┓ ┏┓┳┳┓┏┓┓┏┏┓┓ ┓
#  ┃ ┃ ┣┫┃┃┃┗┓┣┫┣ ┃ ┃
#  ┗┛┗┛┛┗┛ ┗┗┛┛┗┗┛┗┛┗┛


LID_STATE="/proc/acpi/button/lid/LID0/state"

if grep -q closed "$LID_STATE"; then
    hyprctl keyword monitor "eDP-1, disable"
else
    hyprctl keyword monitor "eDP-1, preferred, auto, 1"
fi
