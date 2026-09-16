import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Qt.labs.qmlmodels

import "../config.js" as Config

// Clipboard popup — mismo patrón que AppLauncher.qml.
//
// Misma estructura que el app launcher:
//   • PanelWindow fullscreen con WlrLayershell.layer Overlay
//   • MouseArea fullscreen para click-outside-to-close
//   • Shortcut Escape
//   • Rectangle card (anchored top:parent.top + topMargin:35, debajo
//     del bar) con ColumnLayout adentro: TextField search + ListView
//     de entries + empty state
//
// Lista los entries de `clipvault` (preview por línea) y los restaura
// al clipboard via `clipvault get --index N | wl-copy` al hacer
// click/Enter.
//
// El `clipvault-wrapper.sh` (que escucha el clipboard en background)
// no se toca — sigue guardando entries.
//
// API: required property bool show, required property Item anchorItem,
// signal closed — igual que AppLauncher/SessionMenu.
Scope {
    id: root

    required property bool show

    signal closed

    // --- Query state ---
    property string _query: ""

    // --- Entries (raw lines de clipvault list) ---
    property var _entries: []

    // Bump para forzar re-fetch al abrir el popup.
    property int _refreshNonce: 0

    onShowChanged: {
        menuWindow.visible = root.show
        if (root.show) {
            root._refreshNonce++
        }
    }

    on_RefreshNonceChanged: {
        root._entries = []
        listProcess.running = false
        // Timer 0ms para forzar restart en el próximo tick del event
        // loop — si no, `running = false; running = true` en el mismo
        // call frame se evalúa como un único cambio de estado y el
        // Process no se reinicia.
        restartTimer.restart()
    }

    Timer {
        id: restartTimer
        interval: 0
        repeat: false
        onTriggered: listProcess.running = true
    }

    // Fetch de clipvault list. 4 campos tab-separated.
    // --max-preview-width 100 trunca previews largos para que una
    // entry de 1MB no genere una línea gigante.
    Process {
        id: listProcess
        running: false
        command: ["sh", "-c",
            "clipvault list --max-preview-width 100 -f id,size,last-updated,preview"
        ]
        stdout: SplitParser {
            splitMarker: "\n"
            // Asignamos un nuevo array (no push) para que el binding
            // de `values` del ScriptModel se re-evalúe y la ListView
            // muestre las entries.
            onRead: function(data) {
                root._entries = root._entries.concat([data])
            }
        }
    }

    // Restaurar un entry al clipboard (clipvault es 1-indexed).
    function pick(index) {
        if (index < 0) return
        Quickshell.execDetached(["sh", "-c",
            "clipvault get --index " + (index + 1) + " | wl-copy"
        ])
        root._query = ""
        root.closed()
    }

    // (Sin infraestructura de animación de cierre — igual que
    //  AppLauncher.qml actual, que cierra directo vía root.closed().
    //  Si más adelante querés animación, te agrego el Timer + _closing
    //  flag como hicimos antes.)

    // ---------------------------------------------------------------
    // PanelWindow fullscreen — mismo patrón que AppLauncher.qml.
    // ---------------------------------------------------------------
    PanelWindow {
        id: menuWindow

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        exclusiveZone: 0

        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.layer: WlrLayer.Overlay

        visible: root.show
        color: "transparent"

        onVisibleChanged: {
            if (visible) searchInput.forceActiveFocus()
        }

        // Click-outside-to-close.
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onClicked: root.closed()
        }

        // Escape global: primer ESC limpia la query, segundo cierra.
        Shortcut {
            sequence: "Escape"
            onActivated: {
                if (root._query.length > 0) {
                    root._query = ""
                    searchInput.text = ""
                } else {
                    root.closed()
                }
            }
        }

        Rectangle {
            // Card visible — anclada arriba del contentItem del
            // PanelWindow, debajo del bar.
            id: popup
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 35
            width: 480
            height: column.implicitHeight + 16
            radius: 6
            antialiasing: true
            color: Config.colors.base
        }

        ColumnLayout {
            id: column
            anchors { fill: popup; margins: 6 }
            spacing: 6

            // --------------------------------------------------------
            // Search input
            // --------------------------------------------------------
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                radius: 4
                color: Config.colors.surface
                border.color: searchInput.activeFocus
                    ? Config.colors.base
                    : "transparent"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 6

                    Text {
                        text: "󰍉"
                        color: Config.colors.text
                        font.family: Config.bar.fontFamily
                        font.pixelSize: 12
                    }

                    TextField {
                        id: searchInput
                        Layout.fillWidth: true
                        color: Config.colors.text
                        font.family: Config.bar.fontFamily
                        font.pixelSize: 13
                        clip: true
                        focus: true
                        text: root._query
                        selectByMouse: true

                        background: Rectangle {
                            color: "transparent"
                            border.width: 0
                        }

                        onTextChanged: root._query = text

                        Keys.onDownPressed: {
                            if (resultsList.count > 0) {
                                resultsList.incrementCurrentIndex()
                                resultsList.positionViewAtIndex(resultsList.currentIndex, ListView.Contain)
                            }
                            event.accepted = true
                        }
                        Keys.onUpPressed: {
                            if (resultsList.count > 0) {
                                resultsList.decrementCurrentIndex()
                                resultsList.positionViewAtIndex(resultsList.currentIndex, ListView.Contain)
                            }
                            event.accepted = true
                        }
                        Keys.onReturnPressed: {
                            const idx = resultsList.currentIndex
                            if (idx >= 0) root.pick(idx)
                        }
                    }
                }
            }

            // --------------------------------------------------------
            // Filtered model — parsea cada línea tab-separated y filtra
            // por query (match en preview/id/size, case-insensitive).
            // --------------------------------------------------------
            ScriptModel {
                id: filteredModel

                function parseLine(line) {
                    const parts = line.split("\t")
                    return {
                        id:      parts[0] || "",
                        size:    parts[1] || "",
                        updated: parts[2] || "",
                        preview: parts[3] || line
                    }
                }

                values: {
                    const all = root._entries.map(filteredModel.parseLine)
                    const q = root._query.trim().toLowerCase()
                    if (q === "") return all
                    return all.filter(e =>
                        e.preview.toLowerCase().includes(q)
                        || e.id.toLowerCase().includes(q)
                        || e.size.toLowerCase().includes(q)
                    )
                }
            }

            // --------------------------------------------------------
            // Lista de entries
            // --------------------------------------------------------
            ListView {
                id: resultsList
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: 360
                Layout.maximumHeight: 480
                clip: true

                model: filteredModel
                currentIndex: filteredModel.values.length > 0 ? 0 : -1

                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                delegate: Rectangle {
                    required property var modelData
                    required property int index

                    width: resultsList.width
                    height: 56
                    radius: 4
                    color: resultsList.currentIndex === index
                        ? Config.colors.highlightLow
                        : (mouse.containsMouse ? Config.colors.baseDark : "transparent")

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        anchors.topMargin: 6
                        anchors.bottomMargin: 6
                        spacing: 2

                        Text {
                            Layout.fillWidth: true
                            text: modelData.preview
                            color: Config.colors.text
                            font.family: Config.bar.fontFamily
                            font.pixelSize: 12
                            elide: Text.ElideRight
                            wrapMode: Text.NoWrap
                            maximumLineCount: 2
                        }

                        Text {
                            Layout.fillWidth: true
                            text: "#" + modelData.id
                                + "  ·  " + modelData.size
                                + "  ·  " + modelData.updated
                            color: Config.colors.muted
                            font.family: Config.bar.fontFamily
                            font.pixelSize: 10
                            elide: Text.ElideRight
                        }
                    }

                    MouseArea {
                        id: mouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.pick(index)
                    }
                }
            }

            // --------------------------------------------------------
            // Empty state
            // --------------------------------------------------------
            Text {
                Layout.alignment: Qt.AlignHCenter
                visible: filteredModel.values.length === 0
                text: root._entries.length === 0
                    ? (listProcess.running ? "Cargando\u2026" : "Clipboard vacío")
                    : "Sin resultados"
                color: Config.colors.muted
                font.family: Config.bar.fontFamily
                font.pixelSize: 12
                padding: 8
            }
        }
    }
}