import QtQuick
import Quickshell
import Quickshell.Hyprland
import ".."
import "../components"

PanelWindow {
    id: bar
    anchors { top: true; left: true; right: true }
    implicitHeight: Theme.barHeight
    color: "transparent"

    readonly property bool monitorFocused: Hyprland.focusedMonitor === Hyprland.monitorFor(bar.screen)
    readonly property string activeTitle: {
        const t = Hyprland.activeToplevel?.title ?? "";
        return t.length > 40 ? t.substring(0, 39) + "…" : t;
    }

    Rectangle {
        id: surface
        anchors.fill: parent
        color: Theme.panel
        Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Theme.border }

        // ---- left zone
        Row {
            id: left
            anchors { left: parent.left; leftMargin: Theme.gap; verticalCenter: parent.verticalCenter }
            spacing: Theme.gap * 2
            Workspaces { screen: bar.screen; anchors.verticalCenter: parent.verticalCenter }
            Rectangle { width: 1; height: Theme.barHeight - 12; color: Theme.border; anchors.verticalCenter: parent.verticalCenter }
            ScrambleText {
                anchors.verticalCenter: parent.verticalCenter
                targetText: bar.monitorFocused ? bar.activeTitle : ""
                color: Theme.text
            }
        }

        // ---- center zone
        Clock { anchors.centerIn: parent }

        // ---- right zone
        Row {
            id: right
            anchors { right: parent.right; rightMargin: Theme.gap; verticalCenter: parent.verticalCenter }
            spacing: Theme.gap * 2
            Telemetry { anchors.verticalCenter: parent.verticalCenter }
            Rectangle { width: 1; height: Theme.barHeight - 12; color: Theme.border; anchors.verticalCenter: parent.verticalCenter }
            SysStats { anchors.verticalCenter: parent.verticalCenter }
            Rectangle { width: 1; height: Theme.barHeight - 12; color: Theme.border; anchors.verticalCenter: parent.verticalCenter }
            Audio { anchors.verticalCenter: parent.verticalCenter }
        }

        Scanlines {}
    }
}
