-- Appearance theme - CachyOS style
-- Managed by dotfiles

-- Border colors (CachyOS)
local active_border = { colors = { "#82dccc", "#007d6f" }, angle = 45 }
local inactive_border = "#798bb2"

-- General appearance
hl.config({
    general = {
        gaps_in  = 3,
        gaps_out = 8,
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
        rounding       = 10,
        rounding_power = 2,
        active_opacity   = 0.95,
        inactive_opacity = 0.85,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

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
