import QtQuick
import QtQuick.Shapes
import ".."

// Rectangle with the top-right and bottom-left corners cut at 45deg.
// The signature shape of the design.
Shape {
    id: root
    property color fillColor: Theme.panel
    property color strokeColor: Theme.border
    property real strokeWidth: 1
    property int cut: Theme.bevel

    preferredRendererType: Shape.CurveRenderer
    antialiasing: false

    ShapePath {
        id: p
        fillColor: root.fillColor
        strokeColor: root.strokeColor
        strokeWidth: root.strokeWidth
        joinStyle: ShapePath.MiterJoin
        // inset by half the stroke so the line lands on whole pixels
        readonly property real o: root.strokeWidth / 2
        readonly property real w: root.width - o
        readonly property real h: root.height - o
        readonly property real c: root.cut

        startX: p.o; startY: p.o
        PathLine { x: p.w - p.c; y: p.o }
        PathLine { x: p.w;     y: p.o + p.c }
        PathLine { x: p.w;     y: p.h }
        PathLine { x: p.o + p.c; y: p.h }
        PathLine { x: p.o;     y: p.h - p.c }
        PathLine { x: p.o;     y: p.o }
    }
}
