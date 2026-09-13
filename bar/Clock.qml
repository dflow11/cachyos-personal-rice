import QtQuick
import Quickshell
import ".."
import "../components"

Row {
    spacing: Theme.gap
    SystemClock { id: clock; precision: SystemClock.Seconds }

    MonoText {
        text: Qt.formatDateTime(clock.date, "HH:mm:ss")
        color: Theme.primary
        anchors.verticalCenter: parent.verticalCenter
    }
    MonoText {
        text: Qt.formatDateTime(clock.date, "ddd dd.MM.yy").toUpperCase()
        color: Theme.dim
        font.pixelSize: Theme.fontSize - 2
        anchors.verticalCenter: parent.verticalCenter
    }
}
