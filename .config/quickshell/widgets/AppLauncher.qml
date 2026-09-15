import QtQuick
import Quickshell
import Quickshell.Io
import qs.popups
import "../config.js" as Config

// Botón-trigger del app launcher.
//
// Mismo patrón que widgets/Session.qml:
//   • State interno (showLauncher) + IpcHandler target "launcher"
//     para abrir/cerrar desde un atajo externo (qs ipc / keybind).
//   • Embeds el popup AppLauncher (de qs.popups) anclado al glyph.
//   • Renderiza un glyph inline (sin Rectangle de fondo — el fondo
//     lo provee el pill padre). Esto es lo que el comentario del
//     usuario "no button" pidió: cero chrome, sólo el icono clickable.
//   • El popup emite `closed` cuando se cierra solo (ESC, click afuera)
//     y reseteamos el state.
//
// Uso:
//   import qs.widgets
//   ...
//   AppLauncher { }                       // glyph invisible-background
//
// IPC:
//   qs ipc call launcher toggle           # alterna
//   qs ipc call launcher open             # muestra
//   qs ipc call launcher close            # oculta
//   qs ipc call launcher set true|false   # fuerza estado
//   qs ipc call launcher isOpen           # estado actual
Item {
    id: root
    property bool showLauncher: false

    // Tamaño del icono al Item raíz para que el Row del pill lo
    // coloque con tamaño real.
    implicitWidth: launcherIcon.implicitWidth
    implicitHeight: launcherIcon.implicitHeight

    // ---------------------------------------------------------------
    // IPC: abre/cierra el launcher desde un atajo o un script externo.
    // Las funciones DEBEN tener tipos explícitos en args y retorno
    // para que IpcHandler las registre (mismo detalle que en Session).
    // ---------------------------------------------------------------
    IpcHandler {
        id: launcherIpc
        target: "launcher"
        enabled: true

        function toggle(): void {
            root.showLauncher = !root.showLauncher
        }

        function open(): void {
            root.showLauncher = true
        }

        function close(): void {
            root.showLauncher = false
        }

        function set(state: bool): void {
            root.showLauncher = state
        }

        function isOpen(): bool {
            return root.showLauncher
        }
    }

    AppLauncher {
        id: menu
        show: root.showLauncher

        onClosed: root.showLauncher = false
    }

    // Glyph "apps-grid" de FontAwesome (U+F00B) via JetBrainsMono Nerd Font.
    // Sin Rectangle wrapper — el fondo lo aporta el pill padre (igual que
    // el icono de Session en RightPill).
    Text {
        id: launcherIcon
        anchors.centerIn: parent
        text: "\uF00B"
        color: Config.colors.text
        font.family: Config.bar.fontFamily
        font.pixelSize: 14

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.showLauncher = !root.showLauncher
        }
    }
}
