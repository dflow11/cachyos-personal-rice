import QtQuick
import ".."

// Base label. Also carries the ctOS "decode" effect: decode() scrambles the text and
// reveals it left-to-right without breaking whatever binding feeds `text`.
// Every label decodes in once at session start (Intro.done), staggered left to right.
Text {
    id: root
    font.family: Theme.mono
    font.pixelSize: Theme.fontSize
    color: Theme.text
    renderType: Text.NativeRendering
    verticalAlignment: Text.AlignVCenter

    property int decodeDuration: Theme.animSlow
    property bool decodeOnIntro: true
    readonly property string charset: "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/\\<>#*"
    property string _orig: ""
    property int _revealed: 0
    property bool _decoding: false
    property string _scrambled: ""

    function decode(src) {
        if (src === undefined) src = _decoding ? _orig : text;
        _orig = src; _revealed = 0;
        if (src.length === 0) { anim.stop(); _decoding = false; return; }
        _render(); _decoding = true; anim.restart();
    }
    function _render() {
        let out = _orig.substring(0, _revealed);
        for (let i = _revealed; i < _orig.length; i++)
            out += _orig[i] === " " ? " " : charset[Math.floor(Math.random() * charset.length)];
        _scrambled = out;
    }

    // Overrides `text` only while decoding, then hands the original binding/value back.
    Binding { target: root; property: "text"; value: root._scrambled; when: root._decoding; restoreMode: Binding.RestoreBindingOrValue }

    Timer {
        id: anim
        interval: 30; repeat: true
        onTriggered: {
            const steps = Math.max(1, Math.floor(root.decodeDuration / interval));
            root._revealed += Math.max(1, Math.ceil(root._orig.length / steps));
            if (root._revealed >= root._orig.length) { stop(); root._decoding = false; }
            else root._render();
        }
    }

    Connections {
        target: Intro
        function onDoneChanged() {
            if (!Intro.done || !root.decodeOnIntro || !(root.Window.window?.visible ?? false)) return;
            introDelay.interval = 40 + Math.max(0, Math.round(root.mapToItem(null, 0, 0).x / Math.max(1, root.Window.width) * 500));
            introDelay.restart();
        }
    }
    Timer { id: introDelay; onTriggered: root.decode() }
}
