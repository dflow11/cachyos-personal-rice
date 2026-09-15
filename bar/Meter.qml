import QtQuick
import ".."
import "../components"

// Label + value with a thin fill bar underneath, inside a corner frame.
CornerFrame {
    id: root
    property string label: "CPU"
    property string value: "0%"
    property real fraction: 0      // 0..1
    property bool hot: fraction > 0.8
    property int barWidth: 64

    Column {
        spacing: 3
        Item {
            width: root.barWidth; height: Theme.fontSize + 2
            MonoText { text: root.label; color: Theme.dim; anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter }
            MonoText {
                text: root.value
                color: root.hot ? Theme.warn : Theme.text
                anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                Behavior on color { ColorAnimation { duration: Theme.animFast } }
            }
        }
        Rectangle {
            width: root.barWidth; height: 2; color: Theme.border
            Rectangle {
                height: parent.height
                width: Math.round(parent.width * Math.max(0, Math.min(1, root.fraction)))
                color: root.hot ? Theme.warn : Theme.ctosGray
                Behavior on width { NumberAnimation { duration: Theme.animSlow; easing.type: Easing.InOutSine } }
            }
        }
    }
}
