import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../config.js" as Config

// App launcher popup.
//
// Descubre las apps instaladas al iniciar leyendo los *.desktop de
// /usr/share/applications y ~/.local/share/applications. Quickshell
// 0.3.1 (Arch) todavía no expone Quickshell.Services.DesktopEntries,
// así que lo hacemos con un solo Process + SplitParser (async, no
// bloquea la UI) que produce líneas "file\x1fname\x1fexec\x1ficon".
//
// Visualmente consistente con SessionMenu.qml:
//   • Misma paleta de Config.colors, mismo radius.
//   • Item seleccionado = Config.colors.cyan como fondo, fg invertida.
//   • Foco automático en el search al abrir; ESC primero limpia el texto
//     y un segundo ESC cierra el popup.
//   • ↓/↑ navegan la lista, Enter lanza, vim j/k también.
//
// Estructura:
//   Scope (api igual que SessionMenu.qml)
//     └─ PopupWindow anclado al anchorItem del bar
//         └─ ColumnLayout
//             ├─ Search input
//             └─ ListView de apps filtradas
Scope {
    id: root

    required property bool show

    signal closed

    // --- App database ---
    // Cada item: { name, exec, icon, file }
    //   name  → display name del .desktop
    //   exec  → Exec= con field codes (%u, %F, …) ya removidos
    //   icon  → Icon= string (puede ser Nerd Font codepoint, nombre
    //           del icon theme, o path absoluto)
    //   file  → ruta al .desktop original
    property var _apps: []
    property string _query: ""
    property var _filtered: []

    // --- Icon lookup map ---
    // Quickshell 0.3.1 NO expone QIcon::fromTheme (IconImage es sólo
    // un wrapper de QtQuick.Image sin resolver theme). Para mostrar
    // íconos reales armamos un índice nombre→path escaneando los
    // themes una sola vez al iniciar.
    //
    // Cada entrada: { "<iconName>": "/abs/path/to/file.png", ... }
    property var _iconMap: ({})
    property var _iconLines: []

    function _recomputeFilter() {
        const q = _query.trim().toLowerCase()
        if (q.length === 0) {
            _filtered = _apps
        } else {
            _filtered = _apps.filter(a => a.name.toLowerCase().includes(q))
        }
        // Reset selection al cambiar filtro.
        resultsList.currentIndex = _filtered.length > 0 ? 0 : -1
    }

    on_QueryChanged: _recomputeFilter()
    on_AppsChanged:   _recomputeFilter()

    onShowChanged: menuWindow.visible = root.show

    // ----------------------------------------------------------------
    // Scan de .desktop files al iniciar.
    //
    // Un solo Process async — no bloquea UI. stdout SplitParser acumula
    // líneas (formato: file\x1fname\x1fexec\x1ficon) y al "exited" se
    // construye el array _apps.
    //
    // El shell script:
    //   • Hace find de *.desktop en ambos dirs.
    //   • Para cada archivo: extrae Name=, Exec=, Icon= con grep -m1.
    //   • Salta NoDisplay=true / Hidden=true / Type != Application.
    //   • Salta líneas sin Name o Exec.
    //   • Emite una línea por app, separadores \x1f (no aparecen en
    //     nombres de apps razonables).
    // ----------------------------------------------------------------
    property var _scanLines: []

    Process {
        id: scanProcess
        running: true
        command: ["sh", "-c",
            'find /usr/share/applications "$HOME"/.local/share/applications ' +
            '-type f -name "*.desktop" 2>/dev/null | ' +
            'while IFS= read -r f; do ' +
            '  grep -q "^NoDisplay=true"  "$f" 2>/dev/null && continue; ' +
            '  grep -q "^Hidden=true"     "$f" 2>/dev/null && continue; ' +
            '  grep -q "^Type=" "$f" 2>/dev/null && ' +
            '    ! grep -q "^Type=Application" "$f" 2>/dev/null && continue; ' +
            '  name=$(grep -m1 "^Name="  "$f" 2>/dev/null | cut -d= -f2-); ' +
            '  exec=$(grep -m1 "^Exec="  "$f" 2>/dev/null | cut -d= -f2-); ' +
            '  icon=$(grep -m1 "^Icon="  "$f" 2>/dev/null | cut -d= -f2-); ' +
            '  [ -n "$name" ] && [ -n "$exec" ] || continue; ' +
            '  printf "%s\\x1f%s\\x1f%s\\x1f%s\\n" "$f" "$name" "$exec" "$icon"; ' +
            'done | sort -t"$(printf "\\x1f")" -k2'
        ]
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(data) { root._scanLines.push(data) }
        }
        onExited: function(exitCode, exitStatus) {
            const out = []
            for (const line of root._scanLines) {
                // Trim trailing whitespace/CR; split por \x1f (4 campos).
                const clean = line.replace(/[\r\n]+$/g, "")
                const parts = clean.split("\x1f")
                if (parts.length < 4) continue
                const [file, name, execRaw, icon] = parts
                const exec = root._cleanExec(execRaw)
                if (!exec) continue
                out.push({
                    name: name.trim(),
                    exec: exec,
                    icon: (icon || "").trim(),
                    file: file.trim()
                })
            }
            root._apps = out
            root._scanLines = []   // liberar memoria
        }
    }

    // ----------------------------------------------------------------
    // Scan de íconos — index nombre→path.
    //
    // Quickshell no tiene resolver de icon themes, así que armamos un
    // índice a mano. find/awk recorre /usr/share/icons (todos los
    // themes) y ~/.local/share/icons, deduplica por nombre (primer
    // match gana — hicolor suele aparecer primero). Output: líneas
    // "nombre\x1fpath".
    //
    // Tarda ~1-2s con themes típicos; corre async en paralelo con el
    // scan de apps.
    // ----------------------------------------------------------------
    Process {
        id: iconScanProcess
        running: true
        command: ["sh", "-c",
            'find /usr/share/icons "$HOME"/.local/share/icons ' +
            '-type f \\( -name "*.svg" -o -name "*.png" -o -name "*.xpm" \\) ' +
            '2>/dev/null | ' +
            'awk -F/ \'{ ' +
            '  n=$NF; sub(/\\.[^.]+$/, "", n); ' +
            '  if (!(n in seen)) { seen[n]=$0; print n "\\x1f" $0 } ' +
            '}\''
        ]
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(data) { root._iconLines.push(data) }
        }
        onExited: function(exitCode, exitStatus) {
            const map = {}
            for (const line of root._iconLines) {
                const clean = line.replace(/[\r\n]+$/g, "")
                const parts = clean.split("\x1f")
                if (parts.length >= 2 && !map[parts[0]]) {
                    map[parts[0]] = parts[1]
                }
            }
            root._iconMap = map
            root._iconLines = []
        }
    }

    // Quitar field codes de Exec= (%u, %U, %f, %F, %c, %i, etc.) y colapsar ws.
    function _cleanExec(execLine) {
        if (!execLine) return ""
        return execLine.replace(/%[uUfFcDnNkv]/g, "").replace(/\s+/g, " ").trim()
    }

    // ----------------------------------------------------------------
    // Lanzamiento de la app seleccionada.
    // sh -c con el Exec= parseado — maneja rutas con espacios,
    // variables de entorno y comandos compuestos (igual que rofi/wofi).
    // ----------------------------------------------------------------
    function launch(app) {
        if (!app) return
        Quickshell.execDetached(["sh", "-c", app.exec])
        root._query = ""
        searchInput.text = ""
        root.closed()
    }

    // ----------------------------------------------------------------
    // Popup window — centrado en la pantalla.
    //
    // Quickshell no permite posicionar ventanas con x/y (las windows
    // son wlroots layer-shell, que sólo entiende edge-anchors). Truco
    // estándar para "centrado en pantalla":
    //   1. Anclar el PanelWindow a los 4 bordes → la superficie cubre
    //      toda la pantalla (transparente, no bloquea visualmente
    //      porque color: "transparent").
    //   2. Poner el contenido visible (Rectangle con el launcher) con
    //      anchors.centerIn: parent → queda centrado en la pantalla.
    //
    // Si tenés varios monitores el centrado es sobre TODA la pantalla
    // virtual. Para centrado en el monitor del cursor hay que usar
    // Quickshell.screens + pointer screen — avisame si lo querés así.
    // ----------------------------------------------------------------
    PanelWindow {
        id: menuWindow

        // Surface ocupa toda la pantalla.
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        // Sin zona reservada (es un popup, no un panel).
        exclusiveZone: 0

        // Exclusive focus → captura teclado, Hyprland no se queda
        // con Enter/ESC/etc antes que el popup.
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        // Layer Overlay (encima de todo, incluido el bar). Sin esto,
        // dos surfaces en Layer.Top se apilan desde el mismo borde
        // y el nuestro queda debajo del bar — el overlay arrancaba
        // en y=35 (altura del bar) en vez de y=0.
        WlrLayershell.layer: WlrLayer.Overlay

        // Surface totalmente transparente — el oscurecido fullscreen
        // se sacó. El card ahora "flota" sobre el wallpaper con un
        // shadow propio (ver Rectangle shadow abajo).
        visible: root.show
        color: "transparent"

        onVisibleChanged: {
            if (visible) {
                searchInput.forceActiveFocus()
            } else if (root.show) {
                root.closed()
            }
        }

        // Click-outside-to-close.
        //
        // Es el primer hijo del PanelWindow → queda dibujado DEBAJO del
        // popup card (Rectangle popup) en z-order. Cubre toda la pantalla
        // pero como el popup card está encima con el mismo `parent`, los
        // clicks sobre el card NO llegan a este MouseArea (hit-test va
        // al Rectangle y a sus hijos); sí llegan los clicks en el área
        // exterior del card → cierran el popup.
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onClicked: root.closed()
        }

        // Escape global: primer ESC limpia el query si hay texto,
        // segundo ESC cierra.
        //
        // No gateamos por `!searchInput.activeFocus` porque al abrir
        // el popup el TextInput recibe foco inmediatamente — eso
        // dejaría el Shortcut disabled y ESC no haría nada hasta
        // que el usuario clickee fuera del input. El handler local
        // de TextInput ya se removió, así que no hay doble-acción.
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
            // Card visible del launcher — centrado horizontalmente,
            // pegado a arriba (con margen). parent es el contentItem del
            // PanelWindow (superficie full-screen).
            id: popup
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 35
            width: 460
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
                        text: "󰍉"   // glyph lupa (Nerd Font / FontAwesome)
                        color: Config.colors.text
                        font.family: Config.bar.fontFamily
                        font.pixelSize: 12
                    }

                    TextInput {
                        id: searchInput
                        Layout.fillWidth: true
                        verticalAlignment: TextInput.AlignVCenter
                        color: Config.colors.text
                        font.family: Config.bar.fontFamily
                        font.pixelSize: 13
                        clip: true
                        focus: true
                        text: root._query

                        // Placeholder overlay — TextInput no tiene
                        // placeholderText (eso es de QtQuick.Controls.TextField).
                        Text {
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            text: root._apps.length === 0
                                ? "Cargando\u2026"
                                : "Buscar aplicaci\u00f3n\u2026"
                            color: Config.colors.muted
                            font.family: Config.bar.fontFamily
                            font.pixelSize: 13
                            visible: searchInput.text === ""
                        }

                        onTextChanged: root._query = text

                        // Escape se maneja con un Shortcut global a nivel
                        // del popup (ver más arriba) — sino este handler
                        // dispararía doble junto con el Shortcut.

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
                            if (resultsList.currentIndex >= 0
                                && resultsList.currentIndex < root._filtered.length)
                            {
                                root.launch(root._filtered[resultsList.currentIndex])
                            }
                            event.accepted = true
                        }
                    }
                }
            }

            // --------------------------------------------------------
            // Lista de resultados
            // --------------------------------------------------------
            ListView {
                id: resultsList
                Layout.fillWidth: true
                Layout.preferredHeight: 360
                Layout.maximumHeight: 480
                clip: true

                model: root._filtered
                currentIndex: root._filtered.length > 0 ? 0 : -1

                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                delegate: Rectangle {
                    required property var modelData
                    required property int index

                    width: resultsList.width
                    height: 36
                    radius: 4
                    color: resultsList.currentIndex === index
                        ? Config.colors.highlightLow
                        : (mouse.containsMouse ? Config.colors.baseDark : "transparent")

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 8

                        // Icono del .desktop.
                        //
                        // Quickshell 0.3.1 no resuelve icon themes, así
                        // que miramos en `_iconMap` (indexado por el scan
                        // inicial). Si el Icon= ya es path absoluto lo
                        // usamos directo. Si no hay match, fallback glyph.
                        Item {
                            Layout.preferredWidth: 18
                            Layout.preferredHeight: 18
                            Layout.alignment: Qt.AlignVCenter

                            // Helper reactivo: convierte modelData.icon
                            // → URL válida para Image. Se reactiva al
                            // cambiar modelData.icon o _iconMap.
                            readonly property string iconUrl: {
                                const ic = modelData.icon
                                if (!ic) return ""
                                if (ic.startsWith("/")) return "file://" + ic
                                if (ic.startsWith("file://")) return ic
                                const p = root._iconMap[ic]
                                return p ? "file://" + p : ""
                            }

                            IconImage {
                                id: appIcon
                                anchors.fill: parent
                                source: parent.iconUrl
                                asynchronous: true
                            }

                            // Fallback: glyph apps-grid (FontAwesome
                            // U+F00B) si el icono no se pudo cargar.
                            Text {
                                anchors.fill: parent
                                visible: parent.iconUrl === ""
                                         || appIcon.status === Image.Error
                                text: "\uF00B"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                color: resultsList.currentIndex === index
                                    ? Config.colors.text
                                    : Config.colors.text
                                font.family: Config.bar.fontFamily
                                font.pixelSize: 14
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: modelData.name
                            color: resultsList.currentIndex === index
                                ? Config.colors.text
                                : Config.colors.text
                            font.family: Config.bar.fontFamily
                            font.pixelSize: 13
                            elide: Text.ElideRight
                        }
                    }

                    MouseArea {
                        id: mouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.launch(modelData)
                    }
                }
            }

            // Empty state — la lista filtrada está vacía.
            // Lista pero ninguna coincidencia.
            Text {
                Layout.alignment: Qt.AlignHCenter
                visible: root._apps.length > 0 && root._filtered.length === 0
                text: "Sin resultados"
                color: Config.colors.muted
                font.family: Config.bar.fontFamily
                font.pixelSize: 12
                padding: 8
            }
        }
    }
}
