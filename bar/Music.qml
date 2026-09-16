import QtQuick
import Quickshell.Services.Mpris
import ".."
import "../components"

// Now-playing readout: title — artist decoding in on change, thin progress bar under it.
// Click toggles play/pause, scroll skips tracks. Hidden when no MPRIS player has a track.
Item {
    id: root
    readonly property var players: Mpris.players.values
    readonly property MprisPlayer player: players.find(p => p.isPlaying) ?? players.find(p => p.trackTitle !== "") ?? null
    readonly property string line: {
        if (!player) return "";
        const t = player.trackTitle || "UNTITLED";
        const s = (player.trackArtist ? player.trackArtist + " — " : "") + t;
        return (s.length > 24 ? s.substring(0, 23) + "…" : s).toUpperCase();
    }
    readonly property real frac: player && player.lengthSupported && player.length > 0 ? Math.min(1, player.position / player.length) : 0

    visible: player !== null
    implicitWidth: visible ? frame.implicitWidth : 0
    implicitHeight: frame.implicitHeight

    // position only updates on player events; poll while playing
    Timer { interval: 1000; running: root.player?.isPlaying ?? false; repeat: true; onTriggered: root.player.positionChanged() }

    CornerFrame {
        id: frame
        Column {
            spacing: 3
            Row {
                spacing: 6
                MonoText { text: root.player?.isPlaying ? "▶" : "II"; color: root.player?.isPlaying ? Theme.primary : Theme.dim; font.pixelSize: Theme.fontSize - 2; anchors.verticalCenter: parent.verticalCenter }
                ScrambleText { id: title; targetText: root.line; color: root.player?.isPlaying ? Theme.text : Theme.dim }
            }
            Rectangle {
                width: title.width + 14; height: 2; color: Theme.border
                Rectangle { height: parent.height; width: Math.round(parent.width * root.frac); color: Theme.ctosGray }
            }
        }
    }
    MouseArea {
        anchors.fill: parent
        onClicked: if (root.player?.canTogglePlaying) root.player.togglePlaying()
        onWheel: wheel => { if (!root.player) return; wheel.angleDelta.y < 0 ? (root.player.canGoNext && root.player.next()) : (root.player.canGoPrevious && root.player.previous()); }
    }
}
