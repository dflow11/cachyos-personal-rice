pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Single shared /proc reader. One timer, one set of FileViews, for every bar.
Singleton {
    id: root
    property real cpu: 0            // 0..1
    property real memUsed: 0        // bytes
    property real memTotal: 0       // bytes
    property real uptime: 0         // seconds
    property int historyLen: 20
    property var cpuHistory: []     // most recent last, values 0..1
    property string hostname: "unknown"
    // FNV-1a of hostname -> "XX-XXXX", the decorative node id
    readonly property string nodeId: {
        let h = 0x811c9dc5;
        for (let i = 0; i < hostname.length; i++) { h ^= hostname.charCodeAt(i); h = Math.imul(h, 0x01000193) >>> 0; }
        const hex = h.toString(16).toUpperCase().padStart(8, "0");
        return hex.substring(0, 2) + "-" + hex.substring(2, 6);
    }

    property real _prevTotal: 0
    property real _prevIdle: 0

    FileView {
        id: hostFile
        path: "/etc/hostname"
        blockLoading: true
        onLoaded: root.hostname = text().trim()
    }
    FileView {
        id: statFile
        path: "/proc/stat"
        onLoaded: {
            const line = text().split("\n")[0];
            const f = line.trim().split(/\s+/).slice(1).map(Number);
            // user nice system idle iowait irq softirq steal
            const idle = f[3] + f[4];
            let total = 0; for (let i = 0; i < 8 && i < f.length; i++) total += f[i];
            const dT = total - root._prevTotal, dI = idle - root._prevIdle;
            if (root._prevTotal > 0 && dT > 0) {
                root.cpu = Math.max(0, Math.min(1, 1 - dI / dT));
                let h = root.cpuHistory.slice();
                h.push(root.cpu);
                while (h.length > root.historyLen) h.shift();
                root.cpuHistory = h;
            }
            root._prevTotal = total; root._prevIdle = idle;
        }
    }
    FileView {
        id: memFile
        path: "/proc/meminfo"
        onLoaded: {
            const t = text();
            const g = k => { const m = t.match(new RegExp("^" + k + ":\\s+(\\d+)", "m")); return m ? Number(m[1]) * 1024 : 0; };
            root.memTotal = g("MemTotal");
            root.memUsed = root.memTotal - g("MemAvailable");
        }
    }
    FileView {
        id: uptimeFile
        path: "/proc/uptime"
        onLoaded: root.uptime = Number(text().split(" ")[0])
    }

    Timer {
        interval: 2000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: { statFile.reload(); memFile.reload(); uptimeFile.reload(); }
    }

    function fmtUptime(s) {
        s = Math.floor(s);
        const d = Math.floor(s / 86400); s %= 86400;
        const h = Math.floor(s / 3600); s %= 3600;
        const m = Math.floor(s / 60); s %= 60;
        const p = n => (n < 10 ? "0" : "") + n;
        return (d > 0 ? d + "d " : "") + p(h) + ":" + p(m) + ":" + p(s);
    }
}
