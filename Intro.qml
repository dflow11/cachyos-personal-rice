pragma Singleton
import QtQuick

// Session-start reveal flag. Boot flips it when the splash fades; labels and frames
// decode/grow in when it turns true. On hot reload Boot flips it immediately.
QtObject {
    property bool done: false
}
