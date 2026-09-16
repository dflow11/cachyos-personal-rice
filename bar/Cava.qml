import QtQuick
import Quickshell
import Quickshell.Io
import ".."
import "../components"

// 16-cell audio visualizer fed by cava (raw ascii on stdout). Same look as the CPU sparkline.
// Only runs while something is playing, so it costs nothing idle.
Row {
    id: root
    property bool active: false
    property var levels: []          // 0..100 per bar
    spacing: 1
    height: Theme.barHeight - 14
    readonly property int cellW: 3
    readonly property int bars: 16

    Process {
        id: cava
        command: ["cava", "-p", Quickshell.env("HOME") + "/.config/quickshell/nullgrid/themes/cava.conf"]
        running: root.active
        stdout: SplitParser {
            onRead: line => root.levels = line.split(";").filter(s => s !== "").map(Number)
        }
        onRunningChanged: if (!running) root.levels = []
    }

    Repeater {
        model: root.bars
        delegate: Item {
            required property int index
            readonly property real v: (root.levels[index] ?? 0) / 100
            width: root.cellW; height: root.height
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Theme.border }
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: Math.max(1, Math.round(parent.v * parent.height))
                color: parent.v > 0.85 ? Theme.warn : Theme.ctosGray
            }
        }
    }
}
