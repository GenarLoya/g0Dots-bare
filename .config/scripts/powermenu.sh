#!/usr/bin/env bash
#
# Powermenu (menú de sesión) con rofi.
# Reemplaza el menú de sesión que vivía en Quickshell (widgets/Session.qml).
#
# Uso:
#   ~/.config/scripts/powermenu.sh
#
# Se invoca desde:
#   • Waybar  → custom/powermenu
#   • Hyprland → SUPER + SHIFT + ESCAPE (modules/keybinds.lua)

set -uo pipefail

THEME="${HOME}/.config/rofi/themes/powermenu.rasi"

# ---------------------------------------------------------------------------
# Opciones del menú. "Bloquear" solo aparece si hay un locker instalado.
# ---------------------------------------------------------------------------
options=("Cerrar sesión" "Suspender")

if command -v hyprlock >/dev/null 2>&1; then
    options+=("Bloquear")
fi

options+=("Reiniciar" "Apagar")

# ---------------------------------------------------------------------------
# Picker
# ---------------------------------------------------------------------------
choice=$(printf '%s\n' "${options[@]}" \
    | rofi -dmenu -i -p "Sesión" -theme "${THEME}" 2>/dev/null)

# Escape o nada seleccionado → salir sin hacer nada.
[ -z "${choice}" ] && exit 0

# ---------------------------------------------------------------------------
# Acciones
# ---------------------------------------------------------------------------
case "${choice}" in
    "Cerrar sesión")
        hyprctl dispatch exit
        ;;
    "Suspender")
        systemctl suspend
        ;;
    "Bloquear")
        hyprlock
        ;;
    "Reiniciar")
        systemctl reboot
        ;;
    "Apagar")
        systemctl poweroff
        ;;
    *)
        exit 0
        ;;
esac
