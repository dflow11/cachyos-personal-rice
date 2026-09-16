import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import ".."
import "../components"

Item {
    id: root
    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property bool ready: sink !== null && sink.ready && sink.audio !== null
    readonly property bool muted: ready ? sink.audio.muted : true
    readonly property int vol: ready ? Math.round(sink.audio.volume * 100) : 0

    implicitWidth: frame.implicitWidth
    implicitHeight: frame.implicitHeight

    // Nodes only report volume/mute while explicitly tracked.
    PwObjectTracker { objects: root.sink ? [root.sink] : [] }

    CornerFrame {
        id: frame
        Row {
            spacing: 6
            MonoText { text: "VOL"; color: Theme.dim }
            MonoText {
                text: root.muted ? "---" : String(root.vol).padStart(3, "0")
                color: root.muted ? Theme.dim : (root.vol > 100 ? Theme.warn : Theme.text)
            }
        }
    }
    function setVol(v) { if (root.ready) root.sink.audio.volume = Math.max(0, Math.min(1, v)); }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) popup.visible = !popup.visible;
            else if (root.ready) root.sink.audio.muted = !root.sink.audio.muted;
        }
        onWheel: wheel => {
            if (!root.ready) return;
            const step = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
            root.sink.audio.volume = Math.max(0, Math.min(1, root.sink.audio.volume + step));
        }
    }

    // right-click slider: its own layer parked under the bar's right edge, closes when the pointer leaves it
    PanelWindow {
        id: popup
        visible: false
        screen: root.QsWindow.window?.screen ?? null
        anchors { top: true; right: true }
        margins { right: Theme.gap; top: 4 }
        color: "transparent"
        implicitWidth: 240
        implicitHeight: 44
        exclusiveZone: 0
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "nullgrid-volume"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        Timer { id: leave; interval: 900; onTriggered: popup.visible = false }
        onVisibleChanged: if (visible) leave.restart()     // closes unless the pointer reaches it

        Bevel { anchors.fill: parent; strokeColor: Theme.border }
        Item {
            id: track
            anchors { left: parent.left; right: pct.left; verticalCenter: parent.verticalCenter; leftMargin: 16; rightMargin: 12 }
            height: 14
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width; height: 2; color: Theme.border
                Rectangle {
                    height: parent.height
                    width: Math.round(parent.width * (root.muted ? 0 : root.vol / 100))
                    color: root.vol > 100 ? Theme.warn : Theme.primary
                }
            }
            Rectangle {   // handle
                x: Math.round(parent.width * (root.muted ? 0 : Math.min(1, root.vol / 100))) - 1
                anchors.verticalCenter: parent.verticalCenter
                width: 3; height: 10; color: Theme.ctosGray
            }
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: leave.stop()
                onExited: leave.restart()
                onPressed: mouse => root.setVol(mouse.x / width)
                onPositionChanged: mouse => { if (pressed) root.setVol(mouse.x / width); }
                onWheel: wheel => root.setVol((root.ready ? root.sink.audio.volume : 0) + (wheel.angleDelta.y > 0 ? 0.05 : -0.05))
            }
        }
        MonoText {
            id: pct
            anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
            text: root.muted ? "---" : String(root.vol).padStart(3, "0")
            color: root.muted ? Theme.dim : Theme.text
        }
        MouseArea {   // pad around the track: keeps the popup open while hovering the panel itself
            anchors.fill: parent
            z: -1
            hoverEnabled: true
            onEntered: leave.stop()
            onExited: leave.restart()
        }
        Scanlines {}
    }
}
