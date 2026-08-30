-- Programs configuration
-- Set programs that you use

local terminal    = "ghostty"
local fileManager = "dolphin"
local menu        = "rofi -show drun -config ~/.config/rofi/appdrawer.rasi"
local window      = "rofi -show window -config ~/.config/rofi/appdrawer.rasi"

return {
    terminal    = terminal,
    fileManager = fileManager,
    menu        = menu,
    window      = window,
}
