import QtQuick
import Quickshell.Io
import qs.popups
import "../config.js" as Config

Item {
    id: root
    property bool showPowerMenu: false

    // Propagamos el tamaño del icono al Item raíz para que el Row del pill
    // lo coloque con tamaño real (sino implicitWidth/Height son 0).
    implicitWidth: powerIcon.implicitWidth
    implicitHeight: powerIcon.implicitHeight

    // ---------------------------------------------------------------
    // IPC: permite abrir/cerrar el menú de sesión desde un atajo de
    // teclado (u otro proceso) ejecutando:
    //
    //   qs ipc call session toggle          # alterna
    //   qs ipc call session open            # muestra
    //   qs ipc call session close           # oculta
    //   qs ipc call session set true|false   # fuerza estado
    //   qs ipc call session isOpen          # estado actual
    //
    // Las funciones DEBEN tener tipos explícitos en args y retorno,
    // si no no se registran (ver docs de IpcHandler).
    // ---------------------------------------------------------------
    IpcHandler {
        id: sessionIpc
        target: "session"
        enabled: true

        function toggle(): void {
            root.showPowerMenu = !root.showPowerMenu
        }

        function open(): void {
            root.showPowerMenu = true
        }

        function close(): void {
            root.showPowerMenu = false
        }

        function set(state: bool): void {
            root.showPowerMenu = state
        }

        function isOpen(): bool {
            return root.showPowerMenu
        }
    }

    SessionMenu {
        id: menu
        show: root.showPowerMenu
        anchorItem: powerIcon

        // El popup se cerró solo (ESC o click fuera): reseteamos estado.
        onClosed: root.showPowerMenu = false
    }

    // Glyph power-off de FontAwesome mapeado por JetBrainsMono Nerd Font (U+F011).
    // Se renderiza como un char más — el pill padre ya provee el fondo.
    Text {
        id: powerIcon
        anchors.centerIn: parent
        text: ""
        color: Config.colors.fg
        font.family: Config.bar.fontFamily
        font.pixelSize: 14

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.showPowerMenu = !root.showPowerMenu
        }
    }
}
