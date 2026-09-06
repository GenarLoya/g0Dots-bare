#!/usr/bin/env bash
#
# Picker para restaurar un entry de clipvault al clipboard.
# Usa rofi si está disponible (modo dmenu); si no, usa fzf.
#
# Uso:
#   ./clipvault-pick.sh              # picker visual
#   ./clipvault-pick.sh 0            # restaurar el más reciente sin preguntar
#   ./clipvault-pick.sh --index 1    # explícito
#
# Salida a stderr: logs si CLIPVAULT_DEBUG=1.

set -u

DEBUG_MODE=${CLIPVAULT_DEBUG:-0}
_dbg() { [ "$DEBUG_MODE" = "1" ] && echo "[pick] $*" >&2; }

# ---------------------------------------------------------------------------
# Argumentos opcionales
# ---------------------------------------------------------------------------
if [ $# -ge 1 ]; then
    case "$1" in
        -i|--index) shift; INDEX="$1";;
        -h|--help)
            sed -n '2,12p' "$0"
            exit 0;;
        *) INDEX="$1";;
    esac
else
    INDEX=""
fi

# ---------------------------------------------------------------------------
# Si nos pasaron índice, vamos directo (sin picker)
# ---------------------------------------------------------------------------
if [ -n "${INDEX:-}" ]; then
    _dbg "Restaurando por índice directo: $INDEX"
    clipvault get --index "$INDEX" | wl-copy
    rc=$?
    _dbg "wl-copy rc=$rc"
    exit $rc
fi

# ---------------------------------------------------------------------------
# Picker visual
# ---------------------------------------------------------------------------
_dbg "Listando entries de clipvault..."

# clipvault list devuelve: id<TAB>preview por línea (el más reciente primero).
# Para imágenes, el preview es "[[ binary data 1MB image/png ... ]]".
entries=$(clipvault list --max-preview-width 200 2>/dev/null)

if [ -z "$entries" ]; then
    _dbg "clipvault vacío"
    notify-send "clipvault" "Sin entradas" 2>/dev/null || true
    exit 1
fi

_dbg "Entries disponibles: $(echo "$entries" | wc -l)"

# Construimos un menú legible. Formato por línea: "<id>: <preview>"
menu=$(echo "$entries" | awk -F'\t' '{ printf "%s\t%s\n", $1, $2 }')

_dbg "Lanzando rofi..."

# -i: case-insensitive
# -dmenu: modo entrada
# -p: prompt
# -format 'i': rofi devuelve solo el id (primera columna) de la línea elegida
echo $menu

selection=$(( $(echo "$menu" | rofi -i -dmenu -p "clipvault" -format 'i' 2>/dev/null) + 1 ))

# rofi exit codes:
#   0 = seleccionado
#   1 = sin selección (Escape)
#   >1 = error
rc=$?
_dbg "rofi rc=$rc, selección='$selection'"

if [ -z "$selection" ] || [ "$rc" -ne 0 ]; then
    _dbg "Cancelado por el usuario"
    exit 0
fi

_dbg "Restaurando entry index=$selection"
content=$(clipvault get --index "$selection" 2>/dev/null)
get_rc=$?
_dbg "clipvault get rc=$get_rc, bytes=${#content}"

if [ "$get_rc" -ne 0 ] || [ -z "$content" ]; then
    notify-send "clipvault" "Error al leer entry $selection" 2>/dev/null || true
    exit 1
fi

# wl-copy soporta stdin para texto y binarios (imágenes, etc.).
printf '%s' "$content" | wl-copy
copy_rc=$?
_dbg "  wl-copy rc=$copy_rc"

if [ "$copy_rc" -eq 0 ]; then
    preview=$(echo "$entries" | awk -F'\t' -v id="$selection" '$1 == id { print $2 }' | head -c 60)
    notify-send "clipvault" "Copiado: $preview" 2>/dev/null || true
    _dbg "✔ Entry $selection restaurado al clipboard"
fi

exit $copy_rc
