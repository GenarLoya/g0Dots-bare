#!/usr/bin/env bash
#
# Wrapper que prioriza imagen > uri-list (archivo) > texto, y pipea a `clipvault store`.
#
# Activar tracing:   CLIPVAULT_DEBUG=1 ./clipvault-wrapper.sh
# Xtrace completo:   CLIPVAULT_DEBUG=1 CLIPVAULT_XTRACE=1 ./clipvault-wrapper.sh
#
# Salida:
#   • stdout → bytes para clipvault store (NO contaminar)
#   • stderr → todos los [debug] van acá

set -u

DEBUG_MODE=${CLIPVAULT_DEBUG:-0}
XTRACE=${CLIPVAULT_XTRACE:-0}

_dbg()   { [ "$DEBUG_MODE" = "1" ] && echo "[debug] $*" >&2; }
_enter() { [ "$DEBUG_MODE" = "1" ] && echo "        → $*  (entrando)" >&2; }
_skip()  { [ "$DEBUG_MODE" = "1" ] && echo "        ✗ $*  (saltando)" >&2; }

if [ "$DEBUG_MODE" = "1" ] && [ "$XTRACE" = "1" ]; then
    _dbg "XTRACE activado (set -x)"
    set -x
fi

_dbg "=========================================="
_dbg "inicio wrapper (PID=$$)"
_dbg "=========================================="

# Muestra el entry más reciente de clipvault (con id, tamaño, timestamp).
# Sale silenciosa si DEBUG_MODE!=1.
_show_last_entry() {
    [ "$DEBUG_MODE" != "1" ] && return 0

    _dbg "─── clipvault last entry ───"

    # Pedimos todos los campos para tener metadata completa.
    local entry_line
    entry_line=$(clipvault list --max-preview-width 100 -f id,size,last-updated,preview 2>/dev/null | head -n1)

    if [ -z "$entry_line" ]; then
        _dbg "  (clipvault vacío)"
        return 0
    fi

    local entry_id entry_size entry_updated entry_preview
    # Formato: "<id>\t<size>\t<last-updated>\t<preview>"
    entry_id=$(echo "$entry_line"      | awk -F'\t' '{print $1}')
    entry_size=$(echo "$entry_line"    | awk -F'\t' '{print $2}')
    entry_updated=$(echo "$entry_line" | awk -F'\t' '{print $3}')
    entry_preview=$(echo "$entry_line" | awk -F'\t' '{print $4}')

    _dbg "  ID          : $entry_id"
    _dbg "  Tamaño      : $entry_size"
    _dbg "  Actualizado : $entry_updated"
    _dbg "  Preview     : $entry_preview"
}

# wl-paste consume el clipboard cada vez que se invoca → capturamos 1 vez.
mime_list=$(wl-paste --list-types 2>/dev/null)
wl_paste_rc=$?

_dbg "wl-paste --list-types rc=$wl_paste_rc"
_dbg "MIME types disponibles:"
if [ -n "$mime_list" ]; then
    printf '%s\n' "$mime_list" | sed 's/^/    │ /' >&2
else
    echo "    │ <vacío>" >&2
    _dbg "Sin MIME types → clipboard vacío, saliendo sin error"
    exit 0
fi

# Helper: corre un test y loguea ✓/✗ sin abortar.
_test() {
    local desc="$1"; shift
    if "$@"; then
        _enter "$desc"
        return 0
    else
        _skip "$desc"
        return 1
    fi
}

# ===========================================================================
# PRIORIDAD 1: imagen directa en el clipboard (grim, flameshot, copia de
# imagen desde apps que sí ponen image/png: Firefox image context menu, etc.)
# ===========================================================================
_dbg "─── PRIORIDAD 1: ¿image/* directo en MIME list? ───"
_test "mime_list contiene '^image/'" \
      bash -c "printf '%s\n' '$mime_list' | grep -q '^image/'"

if [ $? -eq 0 ]; then
    _dbg "✔ Ruta 1: pipeando wl-paste --type image/png → clipvault store"
    wl-paste --type image/png | clipvault store
    rc=$?
    _dbg "clipvault store rc=$rc"
    _show_last_entry
    _dbg "=========================================="
    exit $rc
fi

# ===========================================================================
# PRIORIDAD 2: text/uri-list → archivo copiado desde file manager.
#
# IMPORTANTE: Nautilus/GNOME NO ponen image/png cuando copiás un archivo .png,
# usan `x-special/gnome-copied-files` + `text/uri-list` + portal types.
# Por eso Ruta 1 falla para imágenes copiadas desde Nautilus, y tenemos que
# leer el archivo del disco desde el URI.
#
# Esta ruta guarda el CONTENIDO del archivo (no el path) para cualquier tipo.
# ===========================================================================
_dbg "─── PRIORIDAD 2: ¿text/uri-list (file manager)? ───"
_test "mime_list contiene 'text/uri-list'" \
      bash -c "printf '%s\n' '$mime_list' | grep -q 'text/uri-list'"

if [ $? -eq 0 ]; then
    _dbg "→ Rama 2: extrayendo URI"

    uri=$(wl-paste --type text/uri-list 2>/dev/null | head -n1 | tr -d '\r')
    _dbg "  URI cruda : '$uri'"

    # ¿Es un URI file://?
    if [[ "$uri" =~ ^file:// ]]; then
        file_path="${uri#file://}"
        file_path=$(printf '%b' "${file_path//%/\\x}")
        _dbg "  Path local: '$file_path'"

        # ¿El archivo existe en disco?
        _dbg "─── Condicional 2b-i: ¿[ -f file_path ]? ───"
        if [ -f "$file_path" ]; then
            _enter "[ -f '$file_path' ]"
            detected_mime=$(file --mime-type -b "$file_path")
            _dbg "  MIME del archivo en disco: '$detected_mime'"

            # ---- FIX #1 ----
            # Antes: solo guardábamos si detected_mime =~ ^image/
            #   → archivos .txt/.pdf/.sh/etc. caían a Ruta 3 que guardaba
            #     wl-paste --type text/plain (que devuelve el PATH, no el contenido).
            # Ahora: cualquier archivo se guarda por contenido, branch opcional
            #        por MIME para logging (clipvault store recibe bytes igual).
            _dbg "✔ Ruta 2b: archivo local → clipvault store < archivo"
            _dbg "  (bytes del archivo, no el path)"

            # Si el archivo es texto, podríamos querer guardarlo como texto;
            # si es binario, como bytes. clipvault store probablemente no
            # diferencia, pero dejamos log por si hace falta extender.
            case "$detected_mime" in
                image/*) _dbg "  categoría: imagen";;
                text/*)  _dbg "  categoría: texto";;
                *)       _dbg "  categoría: binario ($detected_mime)";;
            esac

            clipvault store < "$file_path"
            rc=$?
            _dbg "  clipvault store rc=$rc"
            _show_last_entry
            _dbg "=========================================="
            exit $rc
        else
            _skip "[ -f '$file_path' ] (no existe en disco)"
        fi
    else
        _skip "URI no es file:// (puede ser http://, data:, etc.)"
    fi
else
    _skip "mime_list NO contiene text/uri-list"
fi

# ===========================================================================
# PRIORIDAD 3: fallback de texto plano.
#
# FIX #2: en vez de pedir text/plain fijo, miramos qué MIME text/* está
# realmente disponible y usamos ese. Si ninguno está disponible (caso
# imagen-only), salimos silenciosamente sin error.
# ===========================================================================
_dbg "─── PRIORIDAD 3: fallback de texto ───"

# Buscamos el primer MIME text/* disponible en orden de preferencia.
text_mime=""
for candidate in "text/plain" "text/plain;charset=utf-8" "text/html" "text/markdown"; do
    if printf '%s\n' "$mime_list" | grep -qxF "$candidate"; then
        text_mime="$candidate"
        _dbg "  Encontrado MIME text/* preferido: '$text_mime'"
        break
    fi
done

if [ -z "$text_mime" ]; then
    _dbg "  No hay MIME text/* disponible → saliendo (nada que guardar)"
    _dbg "=========================================="
    exit 0
fi

_dbg "✔ Ruta 3: wl-paste --type '$text_mime' → clipvault store"
preview=$(wl-paste --type "$text_mime" 2>/dev/null | head -c 80)
_dbg "  Preview (80 chars): '$preview'"

wl-paste --type "$text_mime" | clipvault store
rc=$?
_dbg "  clipvault store rc=$rc"
_show_last_entry
_dbg "=========================================="
exit $rc
