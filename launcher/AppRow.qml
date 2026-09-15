import QtQuick
import ".."
import "../components"

Item {
    id: root
    required property string name
    required property string comment
    required property bool selected
    property int gen: 0
    property int stagger: 0
    signal activated()
    signal hovered()

    onGenChanged: decodeDelay.restart()
    Timer { id: decodeDelay; interval: 40 + root.stagger * 25; onTriggered: label.decode() }

    width: ListView.view ? ListView.view.width : 560
    height: 36

    Rectangle {
        anchors.fill: parent
        color: root.selected ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.06) : "transparent"
    }
    Rectangle {
        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
        width: 1
        color: root.selected ? Theme.primary : Theme.border
    }
    Row {
        anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
        spacing: 12
        ScrambleText {
            id: label
            anchors.verticalCenter: parent.verticalCenter
            targetText: root.name.toUpperCase()
            decodeDuration: Theme.animFast * 2
            color: root.selected ? Theme.primary : Theme.text
        }
        MonoText {
            anchors.verticalCenter: parent.verticalCenter
            text: root.comment
            color: Theme.dim
            font.pixelSize: Theme.fontSize - 1
            elide: Text.ElideRight
            width: 320
        }
    }
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.hovered()
        onClicked: root.activated()
    }
}
