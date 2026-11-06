import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Notifications
import ".."
import "../components"

// Notification daemon. Owns org.freedesktop.Notifications; toasts stack top-right on the
// focused monitor as Bevel panels, newest first, at most maxToasts at a time. Summary
// decodes in, click dismisses, actions on hover-free click are not offered (ponytail:
// actions skipped, add a button row if an app needs them). Everything that arrives is
// also copied into the log, which SUPER+N opens.
Scope {
    id: root

    readonly property int toastW: 380
    readonly property int maxToasts: 3
    readonly property int maxHistory: 50

    // Plain objects, not Notification handles: the server destroys those when they expire,
    // and the log has to outlive them.
    property var history: []

    // Arrival time per notification id. A toast cannot work this out for itself: its
    // delegate is rebuilt every time the stack changes, so `new Date()` in the delegate
    // reports the time of the last rebuild rather than when the message came in.
    property var arrivals: ({})
    function stampFor(id): string { return root.arrivals["n" + id] ?? ""; }

    NotificationServer {
        id: server
        keepOnReload: true
        bodySupported: true
        actionsSupported: false
        imageSupported: false
        onNotification: n => {
            n.tracked = true;
            const stamp = Qt.formatTime(new Date(), "HH:mm:ss");
            root.history = [{
                app: n.appName,
                summary: n.summary,
                body: n.body,
                critical: n.urgency === NotificationUrgency.Critical,
                time: stamp
            }].concat(root.history).slice(0, root.maxHistory);

            // Anything past the cap is already logged, so retire it rather than queue it:
            // a queued toast would only start its timer once it became visible.
            const v = server.trackedNotifications.values;
            for (let i = 0; i < v.length - root.maxToasts; i++) v[i].expire();

            // Rebuild rather than mutate. A var property is stored as a QVariantMap, so
            // every read hands back a copy and an in-place write is silently thrown away.
            // This pass adds the new stamp and drops the ones whose notifications are gone.
            const stamps = {};
            stamps["n" + n.id] = stamp;
            for (const t of server.trackedNotifications.values) {
                const k = "n" + t.id;
                if (stamps[k] === undefined) stamps[k] = root.arrivals[k];
            }
            root.arrivals = stamps;
        }
    }

    function toggleLog(): void { logWin.visible = !logWin.visible; }
    function closeLog(): void { logWin.visible = false; }
    function clearLog(): void { root.history = []; }

    readonly property var list: server.trackedNotifications.values
    // values is oldest-first; take the newest few and flip so the newest sits at the top.
    readonly property var shown: list.slice(-maxToasts).reverse()

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
                model: root.shown
                delegate: Item {
                    id: toast
                    required property Notification modelData
                    readonly property bool critical: modelData.urgency === NotificationUrgency.Critical
                    width: root.toastW
                    height: body.implicitHeight + 2 * 12

                    // auto-expire; critical stays until clicked
                    Timer {
                        running: !toast.critical
                        interval: toast.modelData.expireTimeout > 0 ? toast.modelData.expireTimeout : 3000
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
                            MonoText { text: root.stampFor(toast.modelData.id); color: Theme.dim; font.pixelSize: Theme.fontSize - 2 }
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

    // ---- log (SUPER+N): everything that arrived, newest first, long after the toast went.
    PanelWindow {
        id: logWin
        visible: false
        screen: win.screen
        anchors { top: true; right: true }
        margins { top: Theme.barHeight + Theme.gap; right: Theme.gap }
        color: "transparent"
        implicitWidth: 420
        implicitHeight: 460
        exclusiveZone: 0
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "nullgrid-notify-log"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        Bevel { anchors.fill: parent; fillColor: Theme.panel; strokeColor: Theme.border }

        Item {
            anchors { fill: parent; margins: 16 }

            MonoText {
                id: hdr
                anchors { left: parent.left; top: parent.top }
                text: "NOTIFICATION LOG"
                color: Theme.primary
            }
            MonoText {
                anchors { right: parent.right; baseline: hdr.baseline }
                visible: root.history.length > 0
                text: "CLEAR"
                color: Theme.dim
                font.pixelSize: Theme.fontSize - 2
                decodeOnIntro: false
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.clearLog() }
            }
            Rectangle {
                id: rule
                anchors { left: parent.left; right: parent.right; top: hdr.bottom; topMargin: 8 }
                height: 1
                color: Theme.border
            }
            MonoText {
                anchors { left: parent.left; top: rule.bottom; topMargin: 10 }
                visible: root.history.length === 0
                text: "NO RECORDS"
                color: Theme.dim
                decodeOnIntro: false
            }
            ListView {
                anchors { left: parent.left; right: parent.right; top: rule.bottom; bottom: parent.bottom; topMargin: 10 }
                clip: true
                spacing: 10
                model: root.history
                delegate: Item {
                    id: row
                    required property var modelData
                    width: ListView.view.width
                    height: entry.implicitHeight

                    Rectangle {
                        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                        width: 2
                        color: row.modelData.critical ? Theme.alert : Theme.border
                    }
                    Column {
                        id: entry
                        anchors { left: parent.left; right: parent.right; leftMargin: 10 }
                        spacing: 2
                        Row {
                            spacing: 6
                            MonoText { text: row.modelData.time; color: Theme.dim; font.pixelSize: Theme.fontSize - 2; decodeOnIntro: false }
                            MonoText { text: row.modelData.app.toUpperCase(); color: Theme.dim; font.pixelSize: Theme.fontSize - 2; decodeOnIntro: false }
                        }
                        MonoText {
                            width: parent.width
                            text: row.modelData.summary
                            color: row.modelData.critical ? Theme.alert : Theme.bright
                            elide: Text.ElideRight
                            decodeOnIntro: false
                        }
                        MonoText {
                            width: parent.width
                            visible: text.length > 0
                            text: row.modelData.body
                            color: Theme.text
                            wrapMode: Text.Wrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                            textFormat: Text.PlainText
                            decodeOnIntro: false
                        }
                    }
                }
            }
        }
        MouseArea { anchors.fill: parent; z: -1; onClicked: logWin.visible = false }
        Scanlines {}
    }
}
