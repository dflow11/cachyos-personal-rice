pragma Singleton
import QtQuick

// ctOS / Monoglow palette. Single source of truth — no hardcoded colors elsewhere.
QtObject {
    // surfaces
    readonly property color bg:        "#0E0E0E"
    readonly property color panel:     "#121212"
    readonly property color border:    "#2A2A2A"

    // signal colors
    readonly property color primary:   "#1BFD9C"   // ctOS green — active, focused
    readonly property color dim:       "#7A7A7A"   // inactive text
    readonly property color text:      "#CCCCCC"
    readonly property color bright:    "#F1F1F1"
    readonly property color ctosGray:  "#D9D9D9"   // the ctOS "label block" grey
    readonly property color warn:      "#FFFFFF"   // monochrome design: warn = full white
    readonly property color alert:     "#FC3E38"

    readonly property string mono: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 12
    readonly property int barHeight: 30
    readonly property int gap: 8
    readonly property int bevel: 6      // corner cut size
    readonly property int frameArm: 6   // corner-frame bracket length
    readonly property int animFast: 120
    readonly property int animSlow: 400
}
