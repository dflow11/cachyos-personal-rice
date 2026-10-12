import QtQuick
import Quickshell
import ".."
import "../components"

// Stay-awake indicator. On screen only while an idle inhibitor is held; click to drop it.
MonoText {
    visible: Sys.awake
    text: "AWAKE"
    color: Theme.primary
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Quickshell.execDetached([Quickshell.env("HOME") + "/.local/bin/nullgrid-awake"])
    }
}
