import QtQuick
import Quickshell
import "../config.js" as Config

// Item de menú de sesión reutilizable.
//
// Maneja:
//   • Navegación por teclado (↑/↓ + j/k estilo vim, con wrap si están
//     configurados navUp/navDown circularmente).
//   • Hover y focus visual (color de acento cuando el item tiene el
//     mouse encima o activeFocus).
//   • Confirmación para acciones destructivas (requireConfirm): al
//     activarse entra en estado "confirming" durante confirmTimeout
//     ms; una segunda activación ejecuta la acción.
//   • Cancelación automática del confirm al perder foco.
//
// Uso:
//   SessionMenuItem {
//       label: "Shutdown"
//       icon: "\uf011"
//       colorName: "red"
//       action: ["systemctl", "poweroff"]
//       requireConfirm: true
//       navUp: rebootItem
//       navDown: lockItem        // wrap-around
//       onActionConfirmed: root.closed()
//       onRequestClose: root.closed()
//   }
Rectangle {
    id: rootItem

    // --- Props requeridas ---
    property string label
    property string icon

    // --- Props configurables ---
    property string colorName: "cyan"     // clave en Config.colors
    property var    action                // array de args (execDetached)
                                          // o función () => void
    property bool   requireConfirm: false
    property int    confirmTimeout: 3000  // ms

    // --- Cadena de navegación ---
    property Item navUp
    property Item navDown

    // --- Señales ---
    signal actionConfirmed  // acción ejecutada → cerrar popup
    signal requestClose     // Escape sin confirmar → cerrar popup

    // --- Estado interno ---
    property bool confirming: false

    // --- Defaults ---
    implicitHeight: 42

    // --- Focus y navegación ---
    focus: true
    KeyNavigation.up:   rootItem.navUp
    KeyNavigation.down: rootItem.navDown

    // Cancelar confirm si el foco se va (navegación, click afuera, etc.)
    onActiveFocusChanged: {
        if (!activeFocus && rootItem.confirming)
            rootItem.cancel()
    }

    // --- Auto-cancel del confirm ---
    Timer {
        id: cancelTimer
        interval: rootItem.confirmTimeout
        repeat: false
        onTriggered: rootItem.cancel()
    }

    // --- Visual: fondo ---
    radius: 6
    antialiasing: true
    color: rootItem.confirming
        ? Config.colors.red
        : (mouse.containsMouse || rootItem.activeFocus
            ? Config.colors[rootItem.colorName]
            : Config.colors.bg)

    // --- Visual: texto ---
    Text {
        anchors.centerIn: parent
        text: rootItem.confirming
            ? "󰌑 Confirm " + rootItem.label
            : rootItem.icon + "  " + rootItem.label
        color: (rootItem.confirming
                || mouse.containsMouse
                || rootItem.activeFocus)
            ? Config.colors.bg
            : Config.colors[rootItem.colorName]
        font.family: Config.bar.fontFamily
        font.pixelSize: 13
    }

    // --- Mouse ---
    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: rootItem.activate()
    }

    // =================================================================
    // API pública
    // =================================================================

    // Llamar para ejecutar la acción. Maneja confirm automáticamente.
    function activate() {
        if (rootItem.requireConfirm && !rootItem.confirming) {
            rootItem.confirming = true
            cancelTimer.restart()
            return
        }
        rootItem._execute()
        rootItem.actionConfirmed()
    }

    // Cancelar manualmente (p. ej. desde Escape).
    function cancel() {
        rootItem.confirming = false
        cancelTimer.stop()
    }

    function _execute() {
        if (Array.isArray(rootItem.action)) {
            Quickshell.execDetached(rootItem.action)
        } else if (typeof rootItem.action === "function") {
            rootItem.action()
        }
    }

    // =================================================================
    // Teclado
    // =================================================================

    Keys.onReturnPressed: { rootItem.activate(); event.accepted = true }
    Keys.onEnterPressed:  { rootItem.activate(); event.accepted = true }

    Keys.onEscapePressed: {
        if (rootItem.confirming) {
            rootItem.cancel()
        } else {
            rootItem.requestClose()
        }
        event.accepted = true
    }

    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_J && rootItem.navDown) {
            rootItem.navDown.forceActiveFocus()
            event.accepted = true
        } else if (event.key === Qt.Key_K && rootItem.navUp) {
            rootItem.navUp.forceActiveFocus()
            event.accepted = true
        }
    }
}
