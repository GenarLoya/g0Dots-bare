-- Programs configuration
-- Set programs that you use

local terminal    = "ghostty"
local fileManager = "nautilus"
local clipboard   = "vicinae 'vicinae://launch/clipboard/history?toggle=true'"
local launcher    = "vicinae toggle"

-- El launcher y el historial del clipboard los lleva Vicinae (nativo Wayland).

return {
    terminal    = terminal,
    fileManager = fileManager,
    clipboard   = clipboard,
    launcher    = launcher,
}
