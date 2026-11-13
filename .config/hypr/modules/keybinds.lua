-- Keybindings
-- https://wiki.hypr.land/Configuring/Basics/Binds/

local mainMod = "SUPER"
local programs = require("modules.programs")

-- Terminal
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(programs.terminal))

-- Close window
hl.bind(mainMod .. " + Q", hl.dsp.window.close())

-- File manager
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(programs.fileManager))

-- Launcher (app drawer + command palette)
-- Antes: rofi en modo drun con el tema Rosé Pine de ~/.config/rofi/themes/appdrawer.rasi.
-- Ahora: Vicinae (launcher nativo + historial de clipboard integrado).
hl.bind(mainMod .. " + space", hl.dsp.exec_cmd("vicinae toggle"))

-- Window switcher: antes rofi vía programs.window; ya no se usa.
-- Hyprland tiene Alt-Tab nativo (`cyclenext`), lo dejo libre.

-- Historial del clipboard (Vicinae, Wayland nativo vía data-control-v1)
-- Antes: picker de clipvault + rofi.
-- El parámetro ?toggle=true hace que el atajo cierre la ventana si ya está abierta.
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("vicinae 'vicinae://launch/clipboard/history?toggle=true'"))

-- Powermenu
-- Antes: `qs ipc call session toggle` (Quickshell). Ahora: script de rofi
-- con las acciones de sesión (cerrar sesión / suspender / reiniciar / apagar).
hl.bind(mainMod .. " + SHIFT + ESCAPE", hl.dsp.exec_cmd(programs.powermenu))

-- Pseudo mode
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())

-- Fullscreen (maximize)
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle", mode = "maximized" }))

-- Toggle split (dwindle)
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

-- Focus directions
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Workspaces 1-10
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Mouse binds for window dragging/resizing
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Audio controls
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })

-- Brightness controls
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Media player controls
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- Random wallpaper
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("~/.config/hypr/scripts/random-wallpaper.sh"))

-- Exit Hyprland
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
