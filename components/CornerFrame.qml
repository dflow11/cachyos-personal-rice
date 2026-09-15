import QtQuick
import ".."

// ctOS bracket frame: four L-shaped corner marks around the content.
// Arms grow from 0 when the session reveals (Intro.done).
Item {
    id: root
    property color frameColor: Theme.ctosGray
    property int arm: Theme.frameArm
    property int thickness: 1
    property int padX: 7
    property int padY: 4
    default property alias content: inner.data

    property real _grow: Intro.done ? 1 : 0
    Behavior on _grow { NumberAnimation { duration: Theme.animSlow; easing.type: Easing.OutCubic } }

    implicitWidth: inner.width + 2 * padX
    implicitHeight: inner.height + 2 * padY

    Row { id: inner; x: root.padX; y: root.padY; spacing: 0 }

    component Corner: Item {
        width: root.arm; height: root.arm
        Rectangle { width: root.arm * root._grow; height: root.thickness; color: root.frameColor }
        Rectangle { width: root.thickness; height: root.arm * root._grow; color: root.frameColor }
    }
    Corner { anchors.top: parent.top; anchors.left: parent.left }
    Corner { anchors.top: parent.top; anchors.right: parent.right; rotation: 90 }
    Corner { anchors.bottom: parent.bottom; anchors.right: parent.right; rotation: 180 }
    Corner { anchors.bottom: parent.bottom; anchors.left: parent.left; rotation: 270 }
}
