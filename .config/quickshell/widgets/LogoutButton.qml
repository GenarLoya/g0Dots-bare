import QtQuick
import Quickshell.Io

// Botón del menú de energía.
//
// Mismo patrón que el ejemplo oficial `wlogout` de Quickshell: cada
// botón es un `QtObject` con los datos declarativos, y un `Process`
// hijo que se arranca en `exec()`. Pasar el comando por `sh -c`
// permite usar `$USER`, globs, pipes, etc., cosa que `execDetached`
// con array se queda literal.
QtObject {
    required property string command
    required property string text
    required property string icon
    property int keybind: -1
    property bool quitAfter: false

    id: button

    readonly property var process: Process {
        command: ["sh", "-c", button.command]
    }

    function exec() {
        process.startDetached()
        if (quitAfter) Qt.quit()
    }
}
