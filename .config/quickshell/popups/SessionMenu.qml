import Quickshell
import QtQuick
import QtQuick.Layouts

import qs.ui
import "../config.js" as Config

Scope {
    id: root

    required property bool show
    required property Item anchorItem

    signal closed

    onShowChanged: menuWindow.visible = root.show

    PopupWindow {
        id: menuWindow

        anchor.item: root.anchorItem
        anchor.edges: Edges.Top | Edges.Right
        anchor.gravity: Edges.Bottom | Edges.Left
        anchor.margins.top: 35

        grabFocus: true

        visible: root.show

        implicitWidth: 220
        implicitHeight: column.implicitHeight + 12

        color: "transparent"

        onVisibleChanged: {
            if (visible) {
                // Al abrir el popup, foco al primer item.
                lockItem.forceActiveFocus()
            } else if (root.show) {
                root.closed()
            }
        }

        Rectangle {
            id: bg
            anchors.fill: parent
            radius: 6
            antialiasing: true
            color: Config.colors.bg
        }

        ColumnLayout {
            id: column

            anchors {
                fill: parent
                margins: 6
            }

            spacing: 4

            // ---------------------------------------------------------------
            // Cadena de items. Lock y Shutdown cierran el ciclo (wrap):
            //   lockItem ↓ → logoutItem
            //   shutdownItem ↑ → lockItem
            //
            // Acciones destructivas (Logout, Reboot, Shutdown) llevan
            // requireConfirm: true → al activarlas hay que presionar
            // Enter dos veces (o una vez y esperar confirmTimeout).
            // ---------------------------------------------------------------

            SessionMenuItem {
                id: lockItem
                Layout.fillWidth: true
                label: "Lock"
                icon: ""
                colorName: "cyan"
                action: ["loginctl", "lock-session"]
                requireConfirm: true
                navUp: shutdownItem     // wrap
                navDown: logoutItem
                onActionConfirmed: root.closed()
                onRequestClose: root.closed()
            }

            SessionMenuItem {
                id: logoutItem
                Layout.fillWidth: true
                label: "Logout"
                icon: ""
                colorName: "cyan"
                action: ["loginctl", "terminate-user", Quickshell.env("USER")]
                requireConfirm: true
                navUp: lockItem
                navDown: suspendItem
                onActionConfirmed: root.closed()
                onRequestClose: root.closed()
            }

            SessionMenuItem {
                id: suspendItem
                Layout.fillWidth: true
                label: "Suspend"
                icon: ""
                colorName: "cyan"
                action: ["systemctl", "suspend"]
                requireConfirm: false
                navUp: logoutItem
                navDown: rebootItem
                onActionConfirmed: root.closed()
                onRequestClose: root.closed()
            }

            SessionMenuItem {
                id: rebootItem
                Layout.fillWidth: true
                label: "Reboot"
                icon: ""
                colorName: "cyan"
                action: ["systemctl", "reboot"]
                requireConfirm: true
                navUp: suspendItem
                navDown: shutdownItem
                onActionConfirmed: root.closed()
                onRequestClose: root.closed()
            }

            SessionMenuItem {
                id: shutdownItem
                Layout.fillWidth: true
                label: "Shutdown"
                icon: ""
                colorName: "red"
                action: ["systemctl", "poweroff"]
                requireConfirm: true
                navUp: rebootItem
                navDown: lockItem      // wrap
                onActionConfirmed: root.closed()
                onRequestClose: root.closed()
            }
        }
    }
}
