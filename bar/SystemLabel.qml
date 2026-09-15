import QtQuick
import ".."
import "../components"

// The ctOS "CT|OS" system label: grey block with emblem + CT, then OS in light weight.
Row {
    id: root
    spacing: 3
    property int blockH: Theme.barHeight - 8

    Rectangle {
        width: 58; height: root.blockH
        color: Theme.ctosGray
        anchors.verticalCenter: parent.verticalCenter
        TintedIcon {
            source: Qt.resolvedUrl("../assets/os-icon.svg")
            color: Theme.bg
            width: root.blockH - 5; height: width
            anchors { left: parent.left; leftMargin: 4; verticalCenter: parent.verticalCenter }
        }
        MonoText {
            text: "CT"
            color: Theme.bg
            font.pixelSize: Theme.fontSize + 3
            font.weight: Font.DemiBold
            anchors { right: parent.right; rightMargin: 4; verticalCenter: parent.verticalCenter }
        }
    }
    MonoText {
        text: "OS"
        color: Theme.ctosGray
        font.pixelSize: Theme.fontSize + 9
        font.weight: Font.Light
        anchors.verticalCenter: parent.verticalCenter
    }
}
