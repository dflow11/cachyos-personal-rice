import QtQuick

// CRT scanline overlay. Sits on top of everything, never takes input.
Canvas {
    id: root
    anchors.fill: parent
    z: 999
    opacity: 0.18
    enabled: false                 // no input
    property int spacing: 3
    renderStrategy: Canvas.Cooperative
    layer.enabled: true

    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onPaint: {
        const ctx = getContext("2d");
        ctx.clearRect(0, 0, width, height);
        ctx.fillStyle = "#000000";
        for (let y = 0; y < height; y += spacing)
            ctx.fillRect(0, y, width, 1);
    }
}
