#!/bin/bash
# T480 ALC257 Audio Fix Script
# This applies the correct mixer settings for clear audio

# Set PCM to maximum (bypass softvol processing)
amixer -c 0 set PCM 100% unmute 2>/dev/null

# Set Speaker to 100% (hardware volume)
amixer -c 0 set Speaker 100% unmute 2>/dev/null

# Set Master to 80% (user volume control)
amixer -c 0 set Master 80% unmute 2>/dev/null

# Disable auto-mute (prevents muting issues)
amixer -c 0 set "Auto-Mute Mode" Disabled 2>/dev/null

echo "T480 audio settings applied"
