import QtQuick
import ".."
import "../components"

// Decorative readouts: node id, real uptime, barcode + microtext strips, CPU sparkline.
Row {
    id: root
    spacing: Theme.gap + 4


    Row {
        spacing: 6
        anchors.verticalCenter: parent.verticalCenter
        MonoText { text: "NODE"; color: Theme.dim }
        MonoText { text: Sys.nodeId; color: Theme.dim }
    }
    Row {
        spacing: 6
        anchors.verticalCenter: parent.verticalCenter
        MonoText { text: "UP"; color: Theme.dim }
        MonoText { text: Sys.fmtUptime(Sys.uptime); color: Theme.dim }
    }

    // barcode strip
    TintedIcon {
        anchors.verticalCenter: parent.verticalCenter
        source: Qt.resolvedUrl("../assets/barcode.svg")
        color: Theme.dim
        height: 12; width: 46
    }

    // microtext strip: a window onto the rotated device-text asset
    Item {
        anchors.verticalCenter: parent.verticalCenter
        width: 110; height: 10
        clip: true
        TintedIcon {
            source: Qt.resolvedUrl("../assets/device-text.svg")
            color: Theme.dim
            width: 10; height: 300
            rotation: 90
            transformOrigin: Item.TopLeft
            x: 300; y: 0
        }
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
