import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import ".."
import "../components"

// Workspace overview: every monitor shows its workspaces as scaled frames with the
// windows drawn as labelled boxes. Click a window to focus it, a frame to switch, Esc/outside to close.
Scope {
    id: root
    property bool open: false
    readonly property real scale: 0.2

    function show() { Hyprland.refreshWorkspaces(); Hyprland.refreshToplevels(); open = true; }
    function close() { open = false; }
    function toggle() { open ? close() : show(); }
    function focusWindow(address) { Hyprland.dispatch("hl.dsp.focus({ window = \"address:" + address + "\" })"); close(); }
    function focusWorkspace(id) { Hyprland.dispatch("hl.dsp.focus({ workspace = " + id + " })"); close(); }

    Variants {
        model: Quickshell.screens
        delegate: PanelWindow {
            id: win
            required property ShellScreen modelData
            readonly property HyprlandMonitor mon: Hyprland.monitorFor(modelData)
            readonly property real monX: mon?.lastIpcObject?.x ?? 0
            readonly property real monY: mon?.lastIpcObject?.y ?? 0
            readonly property var wss: Hyprland.workspaces.values
                .filter(w => w.monitor === win.mon && w.id > 0)
                .sort((a, b) => a.id - b.id)

            screen: modelData
            visible: root.open
            color: "transparent"
            anchors { top: true; bottom: true; left: true; right: true }
            exclusiveZone: 0
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "nullgrid-overview"
            WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

            Rectangle {
                anchors.fill: parent
                color: Theme.bg
                opacity: 0.85
                MouseArea { anchors.fill: parent; onClicked: root.close() }
            }
            Item {
                focus: true
                Keys.onEscapePressed: root.close()
                Keys.onPressed: event => { if (event.key === Qt.Key_Tab && event.modifiers & Qt.MetaModifier) { root.close(); event.accepted = true; } }
            }

            MonoText {
                anchors { left: grid.left; bottom: grid.top; bottomMargin: 14 }
                text: "OVERVIEW // " + win.modelData.name + " // " + win.wss.length + " WS"
                color: Theme.dim
            }

            Row {
                id: grid
                anchors.centerIn: parent
                spacing: Theme.gap * 3

                Repeater {
                    model: win.wss
                    delegate: Item {
                        id: cell
                        required property HyprlandWorkspace modelData
                        readonly property bool current: modelData === win.mon?.activeWorkspace
                        width: win.modelData.width * root.scale
                        height: win.modelData.height * root.scale

                        Bevel {
                            anchors.fill: parent
                            fillColor: Theme.panel
                            strokeColor: cell.current ? Theme.primary : Theme.border
                            cut: Theme.bevel * 2
                        }
                        MouseArea { anchors.fill: parent; onClicked: root.focusWorkspace(cell.modelData.id) }
                        MonoText {
                            anchors { left: parent.left; top: parent.top; margins: 10 }
                            text: "WS " + String(cell.modelData.id).padStart(2, "0")
                            color: cell.current ? Theme.primary : Theme.dim
                            font.pixelSize: Theme.fontSize + 2
                        }

                        Repeater {
                            model: cell.modelData.toplevels.values.filter(t => !(t.lastIpcObject?.hidden ?? false))
                            delegate: Rectangle {
                                id: w
                                required property HyprlandToplevel modelData
                                readonly property var ipc: modelData.lastIpcObject ?? {}
                                x: ((ipc.at?.[0] ?? 0) - win.monX) * root.scale
                                y: ((ipc.at?.[1] ?? 0) - win.monY) * root.scale
                                width: Math.max(8, (ipc.size?.[0] ?? 0) * root.scale)
                                height: Math.max(8, (ipc.size?.[1] ?? 0) * root.scale)
                                color: Theme.bg
                                border.width: 1
                                border.color: modelData.activated ? Theme.primary : Theme.ctosGray
                                clip: true
                                MonoText {
                                    anchors { left: parent.left; right: parent.right; top: parent.top; margins: 6 }
                                    text: String(w.ipc.class ?? "").toUpperCase()
                                    color: w.modelData.activated ? Theme.primary : Theme.text
                                    font.pixelSize: Theme.fontSize - 1
                                    elide: Text.ElideRight
                                }
                                MonoText {
                                    anchors { left: parent.left; right: parent.right; top: parent.top; margins: 6; topMargin: 22 }
                                    text: w.modelData.title
                                    color: Theme.dim
                                    font.pixelSize: Theme.fontSize - 2
                                    elide: Text.ElideRight
                                    visible: parent.height > 40
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: w.color = Theme.border
                                    onExited: w.color = Theme.bg
                                    onClicked: root.focusWindow(w.ipc.address)
                                }
                            }
                        }
                    }
                }
            }
            Scanlines {}
        }
    }
}
