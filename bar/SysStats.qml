import QtQuick
import ".."
import "../components"

Row {
    spacing: Theme.gap
    readonly property int cpuPct: Math.round(Sys.cpu * 100)
    readonly property real memFrac: Sys.memTotal > 0 ? Sys.memUsed / Sys.memTotal : 0

    Meter {
        anchors.verticalCenter: parent.verticalCenter
        label: "CPU"; value: cpuPct + "%"; fraction: Sys.cpu
    }
    Meter {
        anchors.verticalCenter: parent.verticalCenter
        label: "MEM"; value: (Sys.memUsed / 1073741824).toFixed(1) + "G"; fraction: memFrac
    }
}
