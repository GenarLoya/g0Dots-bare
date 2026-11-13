#!/usr/bin/env bash
# @vicinae.schemaVersion 1
# @vicinae.title Restart Waybar
# @vicinae.mode silent
# @vicinae.icon ./waybar.svg
# @vicinae.keywords ["waybar", "restart", "reiniciar", "bar"]
# @vicinae.description Reinicia waybar (pkill + relanzar con la config del dotfiles)

pkill -x waybar
sleep 0.5
setsid -f waybar -c "$HOME/.config/waybar/config.jsonc" -s "$HOME/.config/waybar/style.css" >/dev/null 2>&1
