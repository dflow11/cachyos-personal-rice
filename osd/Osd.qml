import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import ".."
import "../components"
import "../bar"

// Volume OSD: a Meter that pops bottom-center on the focused monitor when the
// default sink's volume or mute changes, and hides again after a second.
Scope {
    id: root
    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property bool ready: sink !== null && sink.ready && sink.audio !== null
    property bool armed: false          // ignore the first values that arrive at startup

    PwObjectTracker { objects: root.sink ? [root.sink] : [] }

    Connections {
        target: root.ready ? root.sink.audio : null
        function onVolumeChanged() { root.show() }
        function onMutedChanged() { root.show() }
    }
    onReadyChanged: if (ready) armTimer.start()
    Timer { id: armTimer; interval: 500; onTriggered: root.armed = true }
    Timer { id: hide; interval: 1200; onTriggered: win.visible = false }

    function show() {
        if (!armed) return;
        win.screen = focusedScreen();
        win.visible = true;
        hide.restart();
    }

    function focusedScreen() {
        const fm = Hyprland.focusedMonitor;
        for (const s of Quickshell.screens) if (Hyprland.monitorFor(s) === fm) return s;
        return Quickshell.screens[0];
    }

    PanelWindow {
        id: win
        visible: false
        color: "transparent"
        anchors { bottom: true }
        margins { bottom: 80 }
        implicitWidth: panel.width
        implicitHeight: panel.height
        exclusiveZone: 0
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "nullgrid-osd"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        Bevel {
            id: panel
            width: meter.implicitWidth + 28
            height: meter.implicitHeight + 16
            strokeColor: Theme.border
            Meter {
                id: meter
                anchors.centerIn: parent
                barWidth: 180
                label: root.ready && root.sink.audio.muted ? "MUTE" : "VOL"
                value: root.ready ? (root.sink.audio.muted ? "---" : Math.round(root.sink.audio.volume * 100) + "%") : ""
                fraction: root.ready && !root.sink.audio.muted ? root.sink.audio.volume : 0
                hot: fraction > 1
            }
            Scanlines {}
        }
    }
}
