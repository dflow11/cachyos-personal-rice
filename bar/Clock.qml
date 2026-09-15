import QtQuick
import Quickshell
import ".."
import "../components"

CornerFrame {
    SystemClock { id: clock; precision: SystemClock.Seconds }
    Row {
        spacing: Theme.gap
        MonoText {
            text: Qt.formatDateTime(clock.date, "ddMMyy")
            color: Theme.dim
            anchors.verticalCenter: parent.verticalCenter
        }
        MonoText {
            text: Qt.formatDateTime(clock.date, "HH:mm:ss")
            color: Theme.primary
            anchors.verticalCenter: parent.verticalCenter
        }
        MonoText {
            text: Qt.formatDateTime(clock.date, "ddd").toUpperCase()
            color: Theme.dim
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
