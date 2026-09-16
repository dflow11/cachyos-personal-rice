import QtQuick
import Quickshell.Io
import ".."
import "../components"

// Terse weather readout: WX 21C CLEAR. wttr.in geolocates by IP, so there is nothing to configure.
Item {
    id: root
    property string temp: ""
    property string cond: ""
    visible: temp !== ""
    implicitWidth: visible ? frame.implicitWidth : 0
    implicitHeight: frame.implicitHeight

    // wttr.in conditions are sentences ("Light rain shower"); the bar wants a 3-4 letter code.
    function abbrev(c) {
        const map = [["THUNDER", "STRM"], ["DRIZZLE", "DRZL"], ["RAIN", "RAIN"], ["SNOW", "SNOW"],
                     ["SLEET", "SLET"], ["FOG", "FOG"], ["MIST", "MIST"], ["OVERCAST", "OVC"],
                     ["CLOUD", "CLDY"], ["CLEAR", "CLR"], ["SUNNY", "CLR"]];
        for (const [k, v] of map) if (c.indexOf(k) !== -1) return v;
        return c.split(" ")[0].substring(0, 4);
    }

    Process {
        id: fetch
        command: ["curl", "-sf", "--max-time", "10", "wttr.in/?format=%t|%C"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const p = text.trim().split("|");
                if (p.length < 2) return;
                root.temp = p[0].replace("+", "").replace("°C", "C").replace("°F", "F");
                root.cond = root.abbrev(p[1].trim().toUpperCase());
            }
        }
    }
    Timer { interval: 900000; running: true; repeat: true; onTriggered: fetch.running = true }

    CornerFrame {
        id: frame
        Row {
            spacing: 6
            MonoText { text: "WX"; color: Theme.dim }
            MonoText { text: root.temp; color: Theme.text }
            MonoText { text: root.cond; color: Theme.dim }
        }
    }
}
