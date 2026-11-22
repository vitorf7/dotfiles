// Your own additions to Slate: ~/.config/slate/user/shell.qml
//
// Slate loads this file into itself, so anything Quickshell can do works here: extra
// panels and widgets, timers, commands, `slate ipc call` handlers. Saving it reloads Slate;
// if it has a mistake, Slate keeps running without it and shows the error in a
// notification. It's kept when you update Slate.
//
// Quickshell's docs: https://quickshell.org/docs/
// Slate's own pieces are usable here too, e.g. Config.s (settings), Config.accent,
// Config.tint("#1d222a") (theme colours), Spaces.list.
//
// Examples: remove the "//" in front of the lines of one to try it.

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Scope {
    // A small clock in the bottom right corner of every screen:
    // Variants {
    //     model: Quickshell.screens
    //     PanelWindow {
    //         required property var modelData
    //         screen: modelData
    //         anchors { bottom: true; right: true }
    //         margins { bottom: 12; right: 12 }
    //         implicitWidth: clock.implicitWidth + 20; implicitHeight: 32
    //         color: "transparent"
    //         exclusionMode: ExclusionMode.Ignore
    //         WlrLayershell.layer: WlrLayer.Bottom
    //         Rectangle {
    //             anchors.fill: parent; radius: 8
    //             color: Config.tint("#1d222a")
    //             Text {
    //                 id: clock
    //                 anchors.centerIn: parent
    //                 color: Config.tint("#eef1f5")
    //                 font.family: Config.s.fontFamily; font.pixelSize: Config.text(13)
    //                 SystemClock { id: time; precision: SystemClock.Minutes }
    //                 text: Qt.formatTime(time.date, "hh:mm")
    //             }
    //         }
    //     }
    // }

    // Your own command for `slate ipc call mine hello`:
    // IpcHandler {
    //     target: "mine"
    //     function hello(): void { Quickshell.execDetached(["notify-send", "Hello from your shell.qml"]); }
    // }
}
