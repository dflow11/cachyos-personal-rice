import QtQuick
import Quickshell
import Quickshell.Wayland
import ".."
import "../components"

Item {
    id: root
    implicitWidth: frame.implicitWidth
    implicitHeight: frame.implicitHeight

    SystemClock { id: clock; precision: SystemClock.Seconds }

    CornerFrame {
        id: frame
        Row {
            spacing: Theme.gap
            MonoText {
                text: Qt.formatDateTime(clock.date, "ddMMyy")
                color: Theme.dim
                anchors.verticalCenter: parent.verticalCenter
            }
            MonoText {
                text: Qt.formatDateTime(clock.date, "HH:mm:ss")
                color: Theme.primary
                anchors.verticalCenter: parent.verticalCenter
            }
            MonoText {
                text: Qt.formatDateTime(clock.date, "ddd").toUpperCase()
                color: Theme.dim
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
    MouseArea { anchors.fill: parent; onClicked: cal.visible = !cal.visible }

    // month grid, opens under the clock
    PanelWindow {
        id: cal
        visible: false
        screen: root.QsWindow.window?.screen ?? null
        anchors { top: true }
        margins { top: Theme.barHeight + 4 }
        color: "transparent"
        implicitWidth: 230
        implicitHeight: 215
        exclusiveZone: 0
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "nullgrid-calendar"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        readonly property date today: clock.date
        readonly property int first: new Date(today.getFullYear(), today.getMonth(), 1).getDay()   // 0 = Sunday
        readonly property int days: new Date(today.getFullYear(), today.getMonth() + 1, 0).getDate()

        Bevel { anchors.fill: parent; strokeColor: Theme.border }
        Column {
            anchors { fill: parent; margins: 16 }
            spacing: 8
            MonoText {
                text: Qt.formatDateTime(cal.today, "MMMM yyyy").toUpperCase()
                color: Theme.primary
            }
            Grid {
                columns: 7
                spacing: 4
                Repeater {
                    model: ["S", "M", "T", "W", "T", "F", "S"]
                    delegate: MonoText {
                        required property string modelData
                        width: 24; horizontalAlignment: Text.AlignHCenter
                        text: modelData; color: Theme.border; font.pixelSize: Theme.fontSize - 2
                        decodeOnIntro: false
                    }
                }
                Repeater {
                    model: cal.first + cal.days
                    delegate: MonoText {
                        required property int index
                        readonly property int day: index - cal.first + 1
                        readonly property bool isToday: day === cal.today.getDate()
                        width: 24; horizontalAlignment: Text.AlignHCenter
                        text: day > 0 ? day : ""
                        color: isToday ? Theme.primary : Theme.text
                        font.weight: isToday ? Font.DemiBold : Font.Normal
                        decodeOnIntro: false
                    }
                }
            }
        }
        MouseArea { anchors.fill: parent; z: -1; onClicked: cal.visible = false }
        Scanlines {}
    }
}
