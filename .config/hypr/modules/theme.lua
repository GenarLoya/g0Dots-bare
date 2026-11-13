-- Appearance theme - CachyOS style
-- Managed by dotfiles

-- Border colors (Aura)
-- El borde activo usa el mismo @purple que el workspace activo de waybar.
local active_border = "#a277ff"
local inactive_border = "#798bb2"

-- General appearance
hl.config({
    general = {
        gaps_in  = 2,
        gaps_out = 7,
        border_size = 2,
        col = {
            active_border   = active_border,
            inactive_border = inactive_border,
        },
        resize_on_border = false,
        allow_tearing   = false,
        layout          = "dwindle",
    },
})

-- Window decoration
hl.config({
    decoration = {
        rounding       = 4,
        rounding_power = 2,
        active_opacity   = 0.95,
        inactive_opacity = 0.85,

        blur = {
            enabled  = true,
            size     = 5,
            passes   = 4,
            vibrancy = 0.1696,
        },
    },
})

-- Animations
hl.config({
    animations = {
        enabled = true,
    },
})

hl.animation({ leaf = "global", enabled = true, speed = 3, bezier = "quick" })
