pragma Singleton
import QtQuick

QtObject {
    // surfaces
    readonly property color bg:        "#05070A"
    readonly property color panel:     "#0A0E14"
    readonly property color border:    "#16202B"

    // signal colors
    readonly property color primary:   "#35D6C8"   // cyan — active, focused
    readonly property color dim:       "#3D4B57"   // inactive text
    readonly property color text:      "#B8C4CE"
    readonly property color warn:      "#F2A03D"   // amber
    readonly property color alert:     "#FF4C4C"

    readonly property string mono: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 12
    readonly property int barHeight: 30
    readonly property int gap: 8
    readonly property int bevel: 6      // corner cut size
    readonly property int animFast: 120
    readonly property int animSlow: 400
}
