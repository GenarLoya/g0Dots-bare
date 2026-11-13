-- Programs configuration
-- Set programs that you use

local terminal    = "ghostty"
local fileManager = "dolphin"
local clipboard   = "~/.config/scripts/clipvault-pick.sh"
local powermenu   = "~/.config/scripts/powermenu.sh"
local launcher    = "rofi -show drun -theme ~/.config/rofi/themes/appdrawer.rasi"

-- El launcher y el powermenu dejaron de vivir en Quickshell: ahora son
-- rofi (launcher) y un script propio con rofi (powermenu). El bind del
-- launcher está literal en modules/keybinds.lua.

return {
    terminal    = terminal,
    fileManager = fileManager,
    clipboard   = clipboard,
    powermenu   = powermenu,
    launcher    = launcher,
}
