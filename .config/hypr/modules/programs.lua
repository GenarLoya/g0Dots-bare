-- Programs configuration
-- Set programs that you use

local terminal    = "ghostty"
local fileManager = "dolphin"
local clipboard   = "~/.config/scripts/clipvault-pick.sh"

-- menu (antiguo rofi drun launcher) ya no se usa — el app launcher
-- ahora es Quickshell vía IPC: target "launcher" en widgets/AppLauncher.qml,
-- bind en modules/keybinds.lua: mainMod + space → "qs ipc call launcher toggle".
-- window (antiguo rofi window switcher) tampoco — Hyprland ya hace
-- Alt-Tab nativo; si querés un overview custom hay que armarlo aparte.

return {
    terminal    = terminal,
    fileManager = fileManager,
    clipboard   = clipboard,
}
