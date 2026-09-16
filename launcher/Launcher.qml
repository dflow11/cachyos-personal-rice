import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import ".."
import "../components"

PanelWindow {
    id: root
    visible: false
    color: "transparent"
    anchors { top: true; bottom: true; left: true; right: true }
    exclusiveZone: 0
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "nullgrid-launcher"
    WlrLayershell.keyboardFocus: root.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    property string query: ""
    property int selected: 0
    property int gen: 0                     // bumped on open; rows re-decode with stagger
    readonly property int maxVisible: 8

    // ---- data
    readonly property var apps: {
        const all = DesktopEntries.applications.values.filter(e => !e.noDisplay);
        all.sort((a, b) => a.name.localeCompare(b.name));
        return all;
    }
    // session actions, only reachable by typing so a blind Enter never hits one
    readonly property var power: [
        { name: "Lock",     comment: "ctOS locker",        command: [Quickshell.env("HOME") + "/.local/bin/ctos-lock"] },
        { name: "Logout",   comment: "exit Hyprland",      command: ["hyprctl", "dispatch", "hl.dsp.exit()"] },
        { name: "Suspend",  comment: "systemctl suspend",  command: ["systemctl", "suspend"] },
        { name: "Reboot",   comment: "systemctl reboot",   command: ["systemctl", "reboot"] },
        { name: "Shutdown", comment: "systemctl poweroff", command: ["systemctl", "poweroff"] },
    ]
    // clipboard history, refreshed on open; reachable by typing "clip"
    property var clips: []
    Process {
        id: cliphist
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: root.clips = text.split("\n").filter(l => l !== "").slice(0, 50).map(l => {
                const i = l.indexOf("\t");
                return { name: l.substring(i + 1), comment: "clipboard",
                         command: ["sh", "-c", "cliphist decode " + l.substring(0, i) + " | wl-copy"] };
            })
        }
    }

    readonly property var results: {
        const q = query.trim().toLowerCase();
        if (q === "") return apps;
        if (q.startsWith("clip")) {
            const r = q.substring(4).trim();
            return clips.filter(c => r === "" || c.name.toLowerCase().indexOf(r) !== -1);
        }
        const hit = e => e.name.toLowerCase().indexOf(q) !== -1;
        return apps.filter(hit).concat(power.filter(hit));
    }
    onResultsChanged: selected = 0

    // ---- api (called from IpcHandler)
    function focusedScreen() {
        const fm = Hyprland.focusedMonitor;
        const screens = Quickshell.screens;
        for (let i = 0; i < screens.length; i++)
            if (Hyprland.monitorFor(screens[i]) === fm) return screens[i];
        return screens[0];
    }
    function open() {
        root.screen = focusedScreen();
        query = ""; input.text = ""; selected = 0; gen++;
        cliphist.running = true;
        visible = true;
        input.forceActiveFocus();
    }
    function close() { visible = false; }
    onVisibleChanged: if (visible) input.forceActiveFocus()
    function toggle() { visible ? close() : open(); }

    function launch() {
        const e = results[selected];
        if (!e) return;
        close();
        Quickshell.execDetached(e.command);   // field codes already stripped
    }
    function move(d) {
        if (results.length === 0) return;
        selected = (selected + d + results.length) % results.length;
        list.positionViewAtIndex(selected, ListView.Contain);
    }

    // ---- dim backdrop; click outside closes
    Rectangle {
        anchors.fill: parent
        color: Theme.bg
        opacity: root.visible ? 0.85 : 0
        Behavior on opacity { NumberAnimation { duration: Theme.animFast * 2 } }
        MouseArea { anchors.fill: parent; onClicked: root.close() }
    }

    Bevel {
        id: panel
        anchors.centerIn: parent
        width: 600
        height: 56 + Math.max(1, Math.min(root.maxVisible, root.results.length)) * 36 + 30
        fillColor: Theme.panel
        strokeColor: Theme.primary
        cut: Theme.bevel * 2
        // opens from a 1 px horizontal line
        transform: Scale {
            origin.x: panel.width / 2; origin.y: panel.height / 2
            yScale: root.visible ? 1 : 0.002
            Behavior on yScale { NumberAnimation { duration: Theme.animFast + 60; easing.type: Easing.OutCubic } }
        }

        // header
        Item {
            id: header
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 1 }
            height: 56
            TintedIcon {
                id: emblem
                anchors { left: parent.left; leftMargin: 18; verticalCenter: parent.verticalCenter }
                source: Qt.resolvedUrl("../assets/os-icon.svg")
                color: Theme.primary
                width: 18; height: 18
            }
            MonoText {
                id: prompt
                anchors { left: emblem.right; leftMargin: 12; verticalCenter: parent.verticalCenter }
                text: ">"
                color: Theme.primary
                font.pixelSize: Theme.fontSize + 4
            }
            TextInput {
                id: input
                focus: true
                anchors { left: prompt.right; leftMargin: 12; right: parent.right; rightMargin: 20; verticalCenter: parent.verticalCenter }
                font.family: Theme.mono
                font.pixelSize: Theme.fontSize + 4
                color: Theme.text
                selectionColor: Theme.primary
                selectedTextColor: Theme.bg
                renderType: Text.NativeRendering
                clip: true
                onTextChanged: root.query = text
                Keys.onPressed: event => {
                    switch (event.key) {
                    case Qt.Key_Escape: root.close(); event.accepted = true; break;
                    case Qt.Key_Down:   root.move(1);  event.accepted = true; break;
                    case Qt.Key_Up:     root.move(-1); event.accepted = true; break;
                    case Qt.Key_Tab:    root.move(1);  event.accepted = true; break;
                    case Qt.Key_Backtab: root.move(-1); event.accepted = true; break;
                    case Qt.Key_Return:
                    case Qt.Key_Enter:  root.launch(); event.accepted = true; break;
                    }
                }
                // blinking block cursor
                cursorDelegate: Rectangle {
                    width: 9; color: Theme.primary
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite; running: input.activeFocus
                        NumberAnimation { to: 0; duration: 0 } PauseAnimation { duration: 400 }
                        NumberAnimation { to: 1; duration: 0 } PauseAnimation { duration: 400 }
                    }
                }
            }
            MonoText {
                anchors { right: parent.right; rightMargin: 20; verticalCenter: parent.verticalCenter }
                text: root.results.length + " / " + root.apps.length
                color: Theme.dim
                font.pixelSize: Theme.fontSize - 2
            }
            Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom; leftMargin: 14; rightMargin: 14 } height: 1; color: Theme.border }
        }

        ListView {
            id: list
            anchors { top: header.bottom; left: parent.left; right: parent.right; topMargin: 10; leftMargin: 14; rightMargin: 14 }
            height: Math.min(root.maxVisible, root.results.length) * 36
            clip: true
            interactive: false
            model: root.results
            delegate: AppRow {
                required property var modelData
                required property int index
                name: modelData.name
                comment: modelData.comment
                selected: index === root.selected
                gen: root.gen; stagger: index
                onHovered: root.selected = index
                onActivated: { root.selected = index; root.launch(); }
            }
            MonoText {
                visible: root.results.length === 0
                anchors.centerIn: parent
                text: "NO MATCH"
                color: Theme.dim
            }
        }

        MonoText {
            anchors { bottom: parent.bottom; left: parent.left; bottomMargin: 8; leftMargin: 20 }
            text: "ESC CLOSE   ↑↓ SELECT   ⏎ LAUNCH"
            color: Theme.dim
            font.pixelSize: Theme.fontSize - 3
        }

        Scanlines {}
    }
}
