import QtQuick
import QtQuick.Effects
import ".."

// SVG (white/grey fill) recolored to a Theme color at runtime.
Item {
    id: root
    property url source
    property color color: Theme.text
    implicitWidth: 16; implicitHeight: 16

    Image {
        id: img
        anchors.fill: parent
        source: root.source
        sourceSize: Qt.size(width * 2, height * 2)
        fillMode: Image.PreserveAspectFit
        smooth: true
        visible: false
    }
    MultiEffect {
        anchors.fill: img
        source: img
        colorization: 1.0
        colorizationColor: root.color
    }
}
