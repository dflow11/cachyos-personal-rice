import QtQuick
import Quickshell.Services.SystemTray
import ".."
import "../components"

// Tray icons, tinted to the palette. Left click activates, middle click is the app's secondary action.
// ponytail: no context menus — add a QsMenuOpener panel if an app's menu turns out to matter.
Row {
    id: root
    spacing: 10
    visible: SystemTray.items.values.length > 0

    Repeater {
        model: SystemTray.items
        delegate: TintedIcon {
            id: icon
            required property SystemTrayItem modelData
            source: modelData.icon
            color: area.containsMouse ? Theme.primary : Theme.dim
            width: 14; height: 14
            MouseArea {
                id: area
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                onClicked: mouse => mouse.button === Qt.MiddleButton ? icon.modelData.secondaryActivate() : icon.modelData.activate()
            }
        }
    }
}
