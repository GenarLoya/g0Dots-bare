import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts

import "../config.js" as Config

Scope {
    id: root

    NotificationServer {
        id: server
        actionsSupported: true
        bodySupported: true
        imageSupported: true

        onNotification: n => {
            console.log("got: ", n.summary, '--', n.body, n.expireTimeout)
            n.tracked = true
        }
    }

    PanelWindow {
        id: notificationWindow
        anchors {
            top: true;
            right: true;
        }

        margins {
            top: 35 + 12;
            right: 12;
        }

        implicitWidth: 380
        implicitHeight: Math.max(40, column.implicitHeight)

        color: "transparent"

        exclusionMode: ExclusionMode.Ignore

        ColumnLayout {
            id: column
            width: parent.width
            spacing: 10

            Repeater {
                model: server.trackedNotifications

                delegate: Rectangle {
                    id: card
                    required property var modelData
                    property real progress: 1

                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    // Layout.preferredHeight: layout.implicitHeight
                    radius: 8
                    color: Config.colors.bg
                    border.width: 0
                    border.color: "transparent"

                    // --- Animación de entrada: fade + scale-up desde el borde derecho.
                    // Usamos scale (no x) para no chocar con el posicionamiento del Layout.
                    opacity: 0
                    scale: 0.92
                    transformOrigin: Item.Right

                    Behavior on opacity {
                        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
                    }
                    Behavior on scale {
                        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
                    }

                    Component.onCompleted: {
                        opacity = 1
                        scale = 1
                    }

                    // --- Animación de salida: fade + scale-down, luego dismiss.
                    function animateExit() {
                        exitAnim.restart()
                    }

                    SequentialAnimation {
                        id: exitAnim
                        running: false
                        ParallelAnimation {
                            NumberAnimation {
                                target: card
                                property: "opacity"
                                to: 0
                                duration: 180
                                easing.type: Easing.InCubic
                            }
                            NumberAnimation {
                                target: card
                                property: "scale"
                                to: 0.92
                                duration: 180
                                easing.type: Easing.InCubic
                            }
                        }
                        ScriptAction {
                            script: card.modelData.dismiss()
                        }
                    }


                    RowLayout {
                        id: layout
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        Rectangle {
                            Layout.preferredHeight: 36
                            Layout.preferredWidth: 24
                            Layout.alignment: Qt.AlignTop
                            visible: card.modelData.urgency === NotificationUrgency.Critical
                            radius: 6
                            color: Config.colors.red

                            Text {
                                anchors.centerIn: parent
                                text: "!"
                                color: Config.colors.bgDark
                                font.family: Config.bar.fontFamily
                                font.bold: true
                                font.pixelSize: 20
                            }

                            SequentialAnimation on opacity {
                                running: visible
                                loops: Animation.Infinite
                                NumberAnimation { to: 0.35; duration: 450 }
                                NumberAnimation { to: 1.0; duration: 450 }
                            }
                        }

                        Image {
                            Layout.preferredHeight: 36
                            Layout.preferredWidth: 36
                            Layout.alignment: Qt.AlignTop
                            fillMode: Image.PreserveAspectFit
                            visible: source.toString() !== ""
                            source: card.modelData.image || card.modelData.appIcon || ""
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                Layout.fillWidth: true
                                visible: text !== ""
                                text: card.modelData.summary
                                color: Config.colors.cyan
                                font.family: Config.bar.fontFamily
                                font.bold: true
                                wrapMode: Text.WordWrap
                            }

                            Text {
                                Layout.fillWidth: true
                                visible: text !== ""
                                text: card.modelData.body
                                color: Config.colors.fg
                                font.family: Config.bar.fontFamily
                                wrapMode: Text.WordWrap
                            }
                        }
                    }

                    NumberAnimation on progress {
                        from: 1
                        to: 0
                        duration: dismissTimer.interval
                        running: card.modelData.urgency !== NotificationUrgency.Critical
                        easing.type: Easing.Linear
                    }

                    Rectangle {
                        visible: card.modelData.urgency !== NotificationUrgency.Critical
                        anchors.left: parent.left
                        anchors.leftMargin: 8
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 6
                        width: (parent.width - 16) * card.progress
                        height: 3

                        radius: 2
                        color: Config.colors.cyan
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: card.animateExit()
                    }

                    Timer {
                        id: dismissTimer
                        // expireTimeout (spec D-Bus): > 0 usar ese valor,
                        // = 0 default servidor (5000ms), < 0 persistente.
                        interval: {
                            const t = card.modelData.expireTimeout
                            return t > 0 ? t : 5000
                        }
                        running: card.modelData.urgency !== NotificationUrgency.Critical && interval > 0
                        repeat: false
                        onTriggered: card.animateExit()
                    }
                }
            }
        }
    }
}
