import QtQuick
import Quickshell.Services.Pipewire
import ".."
import "../components"

Item {
    id: root
    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property bool ready: sink !== null && sink.ready && sink.audio !== null
    readonly property bool muted: ready ? sink.audio.muted : true
    readonly property int vol: ready ? Math.round(sink.audio.volume * 100) : 0

    implicitWidth: row.width
    implicitHeight: row.height

    // Nodes only report volume/mute while explicitly tracked.
    PwObjectTracker { objects: root.sink ? [root.sink] : [] }

    Row {
        id: row
        spacing: 6
        MonoText { text: "VOL"; color: Theme.dim }
        MonoText {
            text: root.muted ? "---" : (root.vol < 10 ? " " : "") + root.vol
            color: root.muted ? Theme.dim : (root.vol > 100 ? Theme.warn : Theme.text)
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: if (root.ready) root.sink.audio.muted = !root.sink.audio.muted
        onWheel: wheel => {
            if (!root.ready) return;
            const step = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
            root.sink.audio.volume = Math.max(0, Math.min(1, root.sink.audio.volume + step));
        }
    }
}
