import QtQuick
import ".."
import "../components"

// Decorative readouts: node id, real uptime, CPU sparkline.
Row {
    id: root
    spacing: Theme.gap * 2

    // Stable pseudo node id derived from the hostname.
    readonly property string nodeId: {
        let h = 0x811c9dc5;
        const s = Sys.hostname;
        for (let i = 0; i < s.length; i++) { h ^= s.charCodeAt(i); h = Math.imul(h, 0x01000193) >>> 0; }
        const hex = h.toString(16).toUpperCase().padStart(8, "0");
        return hex.substring(0, 2) + "-" + hex.substring(2, 6);
    }

    Row {
        spacing: 6
        anchors.verticalCenter: parent.verticalCenter
        MonoText { text: "NODE"; color: Theme.dim }
        MonoText { text: root.nodeId; color: Theme.dim }
    }
    Row {
        spacing: 6
        anchors.verticalCenter: parent.verticalCenter
        MonoText { text: "UP"; color: Theme.dim }
        MonoText { text: Sys.fmtUptime(Sys.uptime); color: Theme.dim }
    }

    // Sparkline: 20 cells of CPU history
    Row {
        id: spark
        spacing: 1
        anchors.verticalCenter: parent.verticalCenter
        height: Theme.barHeight - 14
        readonly property int cellW: 3
        Repeater {
            model: Sys.historyLen
            delegate: Item {
                required property int index
                readonly property int offset: Sys.historyLen - Sys.cpuHistory.length
                readonly property real v: index >= offset ? Sys.cpuHistory[index - offset] : 0
                width: spark.cellW; height: spark.height
                // floor line so empty cells still read as a track
                Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Theme.border }
                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: Math.max(1, Math.round(parent.v * parent.height))
                    color: parent.v > 0.8 ? Theme.warn : Theme.primary
                    Behavior on height { NumberAnimation { duration: Theme.animSlow; easing.type: Easing.OutCubic } }
                }
            }
        }
    }
}
