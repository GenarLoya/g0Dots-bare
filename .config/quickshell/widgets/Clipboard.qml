import QtQuick
import Quickshell.Io
import qs.popups
import "../config.js" as Config

// Botón-trigger del clipboard popup.
//
// Mismo patrón que widgets/AppLauncher.qml y widgets/Session.qml:
//   • State interno (showClipboard) + IpcHandler target "clipboard"
//     para abrir/cerrar desde un atajo externo (qs ipc / keybind).
//   • Embeds el popup Clipboard (de qs.popups) anclado al glyph.
//   • Renderiza un glyph inline (sin Rectangle de fondo — el fondo
//     lo provee el pill padre).
//   • El popup emite `closed` cuando se cierra solo (ESC, click fuera,
//     pick de entry), reseteamos el state.
//
// IPC:
//   qs ipc call clipboard toggle         # alterna
//   qs ipc call clipboard open           # muestra
//   qs ipc call clipboard close          # oculta
//   qs ipc call clipboard set true|false # fuerza estado
//   qs ipc call clipboard isOpen         # estado actual
Item {
    id: root
    property bool showClipboard: false

    // Tamaño del icono al Item raíz para que el Row del pill lo coloque
    // con tamaño real (sino implicitWidth/Height son 0).
    implicitWidth: clipboardIcon.implicitWidth
    implicitHeight: clipboardIcon.implicitHeight

    IpcHandler {
        id: clipboardIpc
        target: "clipboard"
        enabled: true

        function toggle(): void {
            root.showClipboard = !root.showClipboard
        }

        function open(): void {
            root.showClipboard = true
        }

        function close(): void {
            root.showClipboard = false
        }

        function set(state: bool): void {
            root.showClipboard = state
        }

        function isOpen(): bool {
            return root.showClipboard
        }
    }

    Clipboard {
        id: menu
        show: root.showClipboard

        // El popup se cerró solo (ESC, click afuera, pick de entry):
        // reseteamos estado.
        onClosed: root.showClipboard = false
    }

    // Glyph clipboard de FontAwesome (U+F0EA) via JetBrainsMono Nerd Font.
    Text {
        id: clipboardIcon
        anchors.centerIn: parent
        text: "\uF0EA"
        color: Config.colors.text
        font.family: Config.bar.fontFamily
        font.pixelSize: 14

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.showClipboard = !root.showClipboard
        }
    }
}