#!/usr/bin/env bash

# Toggle script for hyprsunset
# Usage: ./hyprsunset-toggle.sh

PIDFILE="/tmp/hyprsunset.pid"
notifon="$HOME/.config/swaync/icons/sunset-on.png"
notifoff="$HOME/.config/swaync/icons/sunset-off.png"

if [ -f "$PIDFILE" ] && kill -0 $(cat "$PIDFILE") 2>/dev/null; then
    # hyprsunset is running, kill it
    kill $(cat "$PIDFILE")
    rm "$PIDFILE"
    notify-send -u low -i "$notifoff" " Sunset" " mode: OFF"
else
    # hyprsunset is not running, start it
    hyprsunset -t 4000 &  # Adjust temperature as needed
    echo $! > "$PIDFILE"
    notify-send -u low -i "$notifon" " Sunset" " mode: ON"
fi
