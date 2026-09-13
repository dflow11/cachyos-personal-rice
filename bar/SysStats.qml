import QtQuick
import ".."
import "../components"

Row {
    spacing: Theme.gap * 2
    readonly property int cpuPct: Math.round(Sys.cpu * 100)
    readonly property real memG: Sys.memUsed / 1073741824

    Row {
        spacing: 6
        anchors.verticalCenter: parent.verticalCenter
        MonoText { text: "CPU"; color: Theme.dim }
        MonoText {
            text: (cpuPct < 10 ? " " : "") + cpuPct + "%"
            color: cpuPct > 80 ? Theme.warn : Theme.text
            Behavior on color { ColorAnimation { duration: Theme.animFast } }
        }
    }
    Row {
        spacing: 6
        anchors.verticalCenter: parent.verticalCenter
        MonoText { text: "MEM"; color: Theme.dim }
        MonoText {
            text: memG.toFixed(1) + "G"
            color: (Sys.memTotal > 0 && Sys.memUsed / Sys.memTotal > 0.8) ? Theme.warn : Theme.text
        }
    }
}
