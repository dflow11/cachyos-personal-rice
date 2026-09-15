import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Notifications
import ".."
import "../components"

// Notification daemon. Owns org.freedesktop.Notifications; toasts stack top-right on the
// focused monitor as Bevel panels, summary decodes in, click dismisses, actions on hover-free
// click are not offered (ponytail: actions skipped, add a button row if an app needs them).
Scope {
    id: root

    NotificationServer {
        id: server
        keepOnReload: true
        bodySupported: true
        actionsSupported: false
        imageSupported: false
        onNotification: n => n.tracked = true
    }

    readonly property var list: server.trackedNotifications.values
    readonly property int toastW: 380

    PanelWindow {
        id: win
        visible: root.list.length > 0
        screen: {
            const fm = Hyprland.focusedMonitor;
            for (const s of Quickshell.screens) if (Hyprland.monitorFor(s) === fm) return s;
            return Quickshell.screens[0];
        }
        anchors { top: true; right: true }
        margins { top: Theme.barHeight + Theme.gap; right: Theme.gap }
        implicitWidth: root.toastW
        implicitHeight: Math.max(1, stack.implicitHeight)
        color: "transparent"
        exclusiveZone: 0
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "nullgrid-notify"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        Column {
            id: stack
            width: root.toastW
            spacing: Theme.gap

            Repeater {
                model: root.list
                delegate: Item {
                    id: toast
                    required property Notification modelData
                    readonly property bool critical: modelData.urgency === NotificationUrgency.Critical
                    width: root.toastW
                    height: body.implicitHeight + 2 * 12

                    // auto-expire; critical stays until clicked
                    Timer {
                        running: !toast.critical
                        interval: toast.modelData.expireTimeout > 0 ? toast.modelData.expireTimeout : 6000
                        onTriggered: toast.modelData.expire()
                    }

                    Bevel {
                        anchors.fill: parent
                        fillColor: Theme.panel
                        strokeColor: toast.critical ? Theme.alert : Theme.border
                    }
                    Rectangle {   // left accent
                        anchors { left: parent.left; top: parent.top; bottom: parent.bottom; margins: 1 }
                        width: 2
                        color: toast.critical ? Theme.alert : Theme.primary
                    }

                    Column {
                        id: body
                        anchors { left: parent.left; right: parent.right; top: parent.top; leftMargin: 16; rightMargin: 14; topMargin: 12 }
                        spacing: 4
                        Row {
                            spacing: 6
                            MonoText { text: toast.modelData.appName.toUpperCase(); color: Theme.dim; font.pixelSize: Theme.fontSize - 2 }
                            MonoText { text: "//"; color: Theme.border; font.pixelSize: Theme.fontSize - 2 }
                            MonoText { text: Qt.formatTime(new Date(), "HH:mm:ss"); color: Theme.dim; font.pixelSize: Theme.fontSize - 2 }
                        }
                        ScrambleText {
                            width: parent.width
                            targetText: toast.modelData.summary.toUpperCase()
                            color: toast.critical ? Theme.alert : Theme.bright
                            elide: Text.ElideRight
                            Component.onCompleted: decode(targetText)
                        }
                        MonoText {
                            width: parent.width
                            visible: text.length > 0
                            text: toast.modelData.body
                            color: Theme.text
                            wrapMode: Text.Wrap
                            maximumLineCount: 4
                            elide: Text.ElideRight
                            textFormat: Text.PlainText
                        }
                    }

                    MouseArea { anchors.fill: parent; onClicked: toast.modelData.dismiss() }
                    Scanlines {}
                }
            }
        }
    }
}
