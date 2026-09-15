import QtQuick
import ".."

// Text that decodes left-to-right whenever targetText changes.
MonoText {
    property string targetText: ""
    text: targetText
    onTargetTextChanged: decode(targetText)
}
