import Quickshell
import Quickshell.Hyprland
import QtQuick
import "../config.js" as Config

Item {
    id: root

    property int spacing: 4

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Row {
        id: row
        anchors.centerIn: parent
        spacing: root.spacing

        Repeater {
            model: Hyprland.workspaces

            delegate: Rectangle {
                required property HyprlandWorkspace modelData
                readonly property var ws: modelData
                readonly property bool isActive: Hyprland.focusedWorkspace?.id === ws.id
                readonly property bool isEmpty: ws.toplevels.count === 0

                width: isActive ? 18 : 10
                height: 10
                radius: height / 2

                color: isActive ? Config.colors.cyan : (isEmpty ? Config.colors.muted : Config.colors.blue)

                Behavior on width { NumberAnimation { duration: 150 } }

                MouseArea {
                    anchors.fill: parent
                    onClicked: ws.activate()
                }
            }
        }
    }
}
