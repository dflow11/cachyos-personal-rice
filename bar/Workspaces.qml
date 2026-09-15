import QtQuick
import Quickshell
import Quickshell.Hyprland
import ".."
import "../components"

// Fixed-width numbered cells for workspaces 1..count.
// Corner-frame bracket follows the workspace active on THIS bar's monitor.
Item {
    id: root
    required property ShellScreen screen
    property int count: 5
    property int cellW: 24
    property int cellH: Theme.barHeight - 8

    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(screen)
    readonly property int activeId: monitor?.activeWorkspace?.id ?? -1

    implicitWidth: row.width
    implicitHeight: cellH

    function wsById(id) {
        const ws = Hyprland.workspaces.values;
        for (let i = 0; i < ws.length; i++) if (ws[i].id === id) return ws[i];
        return null;
    }
    readonly property var ids: {
        const ws = Hyprland.workspaces.values;
        let max = count;
        for (let i = 0; i < ws.length; i++) if (ws[i].id > max) max = ws[i].id;
        let a = []; for (let i = 1; i <= max; i++) a.push(i); return a;
    }

    Row {
        id: row
        spacing: 0
        Repeater {
            model: root.ids
            delegate: Item {
                required property int modelData
                readonly property var ws: root.wsById(modelData)
                readonly property bool occupied: ws !== null && (ws.lastIpcObject.windows ?? 0) > 0
                readonly property bool focused: modelData === root.activeId
                width: root.cellW; height: root.cellH
                MonoText {
                    anchors.centerIn: parent
                    text: parent.modelData
                    color: parent.focused ? Theme.primary : (parent.occupied ? Theme.text : Theme.dim)
                    Behavior on color { ColorAnimation { duration: Theme.animFast } }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + parent.modelData + " })")
                }
            }
        }
    }

    // Sliding bracket frame
    CornerFrame {
        visible: root.activeId > 0
        x: root.ids.indexOf(root.activeId) * root.cellW
        y: 0
        width: root.cellW; height: root.cellH
        arm: 5
        Behavior on x { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }
    }
}
