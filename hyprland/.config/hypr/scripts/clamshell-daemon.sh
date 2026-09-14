#!/usr/bin/env bash
# Long-running daemon that applies clamshell mode when the lid state changes.
#
# The ThinkPad T480 lid switch fires as a raw evdev EV_SW/SW_LID input event,
# not as a udev button subsystem event, so udevadm monitoring does not catch it.
# Instead we poll /proc/acpi/button/lid/*/state which always reflects the current
# hardware state regardless of how the kernel routes the input event.
#
# Polling interval: 0.5 s — fast enough to feel instant, negligible CPU.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAMSHELL="$SCRIPT_DIR/clamshell.sh"

get_lid_state() {
    # Returns "open" or "closed".  The glob covers LID0, LID, etc.
    awk '{print $2}' /proc/acpi/button/lid/*/state 2>/dev/null | head -1
}

# Wait for Hyprland IPC to become ready before the first hyprctl call.
for _ in $(seq 1 20); do
    hyprctl monitors &>/dev/null && break
    sleep 0.3
done

# Apply the correct state immediately (handles "started with lid already closed").
"$CLAMSHELL" check
prev_state="$(get_lid_state)"

# Poll for state changes.
while true; do
    sleep 0.5
    state="$(get_lid_state)"
    if [[ "$state" != "$prev_state" ]]; then
        prev_state="$state"
        "$CLAMSHELL" check
    fi
done
