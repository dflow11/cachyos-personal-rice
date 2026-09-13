import QtQuick
import ".."

// Text that "decodes" left-to-right whenever targetText changes.
MonoText {
    id: root
    property string targetText: ""
    property int duration: Theme.animSlow
    property string charset: "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/\\<>#*"
    property int _revealed: 0
    readonly property int _tick: 30

    onTargetTextChanged: {
        _revealed = 0;
        anim.restart();
        _render();
    }

    function _render() {
        const t = targetText;
        const n = t.length;
        let out = t.substring(0, _revealed);
        for (let i = _revealed; i < n; i++) {
            if (t[i] === " ") { out += " "; continue; }
            out += charset[Math.floor(Math.random() * charset.length)];
        }
        text = out;
    }

    Timer {
        id: anim
        interval: root._tick
        repeat: true
        onTriggered: {
            const steps = Math.max(1, Math.floor(root.duration / root._tick));
            root._revealed += Math.max(1, Math.ceil(root.targetText.length / steps));
            if (root._revealed >= root.targetText.length) {
                root._revealed = root.targetText.length;
                root.text = root.targetText;
                stop();
            } else {
                root._render();
            }
        }
    }
}
