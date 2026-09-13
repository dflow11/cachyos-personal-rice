import QtQuick
import Quickshell
import Quickshell.Io
import "bar"
import "launcher"

Scope {
    id: root

    Variants {
        model: Quickshell.screens
        delegate: Bar {
            required property ShellScreen modelData
            screen: modelData
        }
    }

    Launcher { id: launcher }

    IpcHandler {
        target: "launcher"
        function toggle(): void { launcher.toggle(); }
        function open(): void { launcher.open(); }
        function close(): void { launcher.close(); }
    }
}
