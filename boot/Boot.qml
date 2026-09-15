import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import ".."
import "../components"

// ctOS boot sequence. Covers every monitor at session start; the focused one types a few
// status lines and the CT|OS splash, then everything fades and Intro.done flips.
// Runs once per Hyprland session: a marker dir in XDG_RUNTIME_DIR makes hot reloads
// and manual `qs` restarts skip straight to Intro.done.
Scope {
    id: root
    property bool active: false
    readonly property string mainScreen: Hyprland.focusedMonitor?.name ?? (Quickshell.screens[0]?.name ?? "")

    readonly property string script: {
        const links = Quickshell.screens.map(s => {
            const hz = Hyprland.monitorFor(s)?.lastIpcObject?.refreshRate;
            return "LINK " + s.name + (hz ? " " + Math.round(hz) + "HZ" : "");
        });
        return ["NODE " + Sys.nodeId + " ONLINE"].concat(links, ["LOADING NULLGRID", "OK"]).map(l => "» " + l).join("\n");
    }

    // timeline state, bound by every window
    property int typed: 0
    property real barX: 0
    property real barY: 0.7
    property real osOn: 0
    property real ctOn: 0
    property real fade: 1

    Process {
        command: ["mkdir", Quickshell.env("XDG_RUNTIME_DIR") + "/nullgrid-boot." + Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE")]
        running: true
        onExited: code => { if (code === 0) root.active = true; else Intro.done = true; }
    }

    SequentialAnimation {
        running: root.active
        ParallelAnimation {
            NumberAnimation { target: root; property: "typed"; from: 0; to: 100; duration: 1000 }   // 100 chars/s, script is shorter
            SequentialAnimation {
                PauseAnimation { duration: 300 }
                NumberAnimation { target: root; property: "barX"; to: 0.4; duration: 500 }
            }
        }
        NumberAnimation { target: root; property: "barX"; to: 1; duration: 200; easing.type: Easing.OutSine }
        PauseAnimation { duration: 100 }
        NumberAnimation { target: root; property: "barY"; to: 1; duration: 250; easing.type: Easing.OutCubic }
        PauseAnimation { duration: 150 }
        PropertyAction { target: root; property: "osOn"; value: 1 }
        NumberAnimation { target: root; property: "barX"; to: 0.73; duration: 250; easing.type: Easing.OutQuart }
        NumberAnimation { target: root; property: "ctOn"; to: 1; duration: 100 }
        PauseAnimation { duration: 400 }
        ScriptAction { script: Intro.done = true }
        NumberAnimation { target: root; property: "fade"; to: 0; duration: 400; easing.type: Easing.InCubic }
        ScriptAction { script: root.active = false }
    }

    Variants {
        model: Quickshell.screens
        delegate: PanelWindow {
            id: win
            required property ShellScreen modelData
            readonly property bool main: modelData.name === root.mainScreen
            screen: modelData
            visible: root.active
            color: "transparent"
            anchors { top: true; bottom: true; left: true; right: true }
            exclusiveZone: 0
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "nullgrid-boot"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            Rectangle {
                anchors.fill: parent
                color: Theme.bg
                opacity: root.fade

                Item {
                    id: splash
                    visible: win.main
                    anchors.centerIn: parent
                    width: 420; height: 64

                    MonoText {
                        decodeOnIntro: false
                        anchors { left: parent.left; bottom: parent.top; bottomMargin: 40 }
                        text: root.script.substring(0, root.typed)
                        color: Theme.dim
                        font.pixelSize: 14
                        lineHeight: 1.4
                    }
                    Rectangle {
                        color: Theme.ctosGray
                        width: parent.width * root.barX
                        height: parent.height * root.barY
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    MonoText {
                        decodeOnIntro: false
                        text: "OS"; opacity: root.osOn; color: Theme.bright
                        font.pixelSize: 64; font.weight: Font.Light
                        anchors { right: parent.right; baseline: parent.bottom; baselineOffset: -3 }
                    }
                    MonoText {
                        decodeOnIntro: false
                        text: "CT"; opacity: root.ctOn; color: Theme.bg
                        font.pixelSize: 34; font.weight: Font.Medium
                        anchors { left: parent.left; leftMargin: 0.58 * parent.width; baseline: parent.bottom; baselineOffset: -5 }
                    }
                }
                Scanlines { visible: win.main }
            }
        }
    }
}
