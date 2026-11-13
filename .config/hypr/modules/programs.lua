-- Programs configuration
-- Set programs that you use

local terminal    = "ghostty"
local fileManager = "dolphin"
local clipboard   = "vicinae 'vicinae://launch/clipboard/history?toggle=true'"
local powermenu   = "~/.config/scripts/powermenu.sh"
local launcher    = "vicinae toggle"

-- El launcher y el historial del clipboard los lleva Vicinae (nativo Wayland).
-- El powermenu sigue con rofi vía script propio.

return {
    terminal    = terminal,
    fileManager = fileManager,
    clipboard   = clipboard,
    powermenu   = powermenu,
    launcher    = launcher,
}
