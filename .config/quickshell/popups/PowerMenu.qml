import Quickshell
import QtQuick
import QtQuick.Controls
import qs.widgets

Item {
    id: root
    implicitWidth: 24
    implicitHeight: 24

    // Los botones se pasan como hijos del componente (igual que en el
    // ejemplo oficial: `WLogout { LogoutButton { ... } }`). Esto deja el
    // componente genérico y la lista se define en quien lo usa.
    default property list<LogoutButton> buttons

    Text {
        id: icon
        anchors.centerIn: parent
        text: "\u23FB"
        font.family: "JetBrainsMono Nerd Font Mono"
        font.pixelSize: 16
        color: popup.opened ? "#f38ba8" : "#cdd6f4"
    }

    MouseArea {
        anchors.fill: icon
        cursorShape: Qt.PointingHandCursor
        onClicked: popup.opened ? popup.close() : popup.open()
    }

    Popup {
        id: popup

        // Como el botón vive en el borde derecho de la barra, abrir
        // hacia la izquierda: borde derecho del popup = borde derecho
        // del icono. Si lo mueves al lado izquierdo del shell, cambia
        // esta línea por `(parent.width - width) / 2`.
        x: parent.width - width
        y: icon.height + 8

        width: 180
        padding: 8
        modal: false
        focus: false
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            radius: 8
            color: "#1e1e2e"
            border.color: "#45475a"
            border.width: 1
        }

        contentItem: Column {
            spacing: 2

            Repeater {
                model: root.buttons
                delegate: ItemDelegate {
                    required property LogoutButton modelData
                    width: popup.availableWidth
                    padding: 8

                    contentItem: Row {
                        spacing: 8

                        Text {
                            text: modelData.icon
                            font.family: "JetBrainsMono Nerd Font Mono"
                            font.pixelSize: 14
                            color: "#cdd6f4"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: modelData.text
                            color: "#cdd6f4"
                            font.family: "JetBrainsMono Nerd Font Mono"
                            font.pixelSize: 13
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    background: Rectangle {
                        radius: 4
                        color: parent.hovered ? "#313244" : "transparent"
                    }

                    onClicked: {
                        modelData.exec()
                        popup.close()
                    }
                }
            }
        }
    }
}
