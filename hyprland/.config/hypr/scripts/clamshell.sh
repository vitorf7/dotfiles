#!/usr/bin/env bash
# Clamshell mode helper for the T480 desk setup.
#
# Usage: clamshell.sh [open|close|check]
#   close  – disable eDP-1 (called when lid closes)
#   open   – re-enable eDP-1 at its exact position (called when lid opens)
#   check  – read the current lid state and apply the right action
#
# The monitor string in EDPS_ON must match monitors.lua exactly so that
# Hyprland restores the correct mode/position/scale.

INTERNAL="eDP-1"

# Count all physical monitors (including disabled ones).
# If the count is 1 we only have the internal screen → don't disable it.
total_monitors() {
    hyprctl monitors all 2>/dev/null | grep -c "^Monitor"
}

cmd_close() {
    if [[ "$(total_monitors)" -gt 1 ]]; then
        hyprctl eval "hl.monitor({ output = 'eDP-1', disabled = true })"
    fi
}

cmd_open() {
    # Must match hl.monitor() in monitors.lua exactly (mode, position, scale).
    hyprctl eval "hl.monitor({ output = 'eDP-1', disabled = false, mode = '1920x1080@60', position = '3840x0', scale = 1 })"
}

cmd_check() {
    # /proc/acpi/button/lid/*/state contains "open" or "closed".
    if grep -q "closed" /proc/acpi/button/lid/*/state 2>/dev/null; then
        cmd_close
    else
        cmd_open
    fi
}

case "$1" in
    close) cmd_close ;;
    open)  cmd_open  ;;
    check) cmd_check ;;
    *) echo "Usage: $(basename "$0") [open|close|check]" >&2; exit 1 ;;
esac
