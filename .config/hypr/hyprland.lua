-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- Hyprland Configuration (Lua format - v0.55+)           --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Load modules
require("modules.env")
require("modules.animations")
require("modules.keybinds")
require("modules.windowrules")
require("modules.workspace_rules")

------------------
---- MONITORS ----
------------------

-- https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Auto-detect monitors (default behavior)
-- Uncomment and modify below for manual monitor configuration
-- hl.monitor({
--     output   = "HDMI-A-1",
--     mode     = "1920x1080@60",
--     position = "0x0",
--     scale    = 1,
-- })

-----------------------
----- PERMISSIONS -----
-----------------------

-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
-- Cursor settings are in hl.config() below

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 5,
        border_size = 2,
        col = {
            active_border   = "#df6124",
            inactive_border = "#505050",
        },
        resize_on_border = false,
        allow_tearing   = false,
        layout          = "dwindle",
    },

    cursor = {
        invisible              = false,
        sync_gsettings_theme  = true,
        no_hardware_cursors    = 2,
        no_break_fs_vrr        = 2,
        inactive_timeout       = 333,
        persistent_warps       = true,
        warp_on_toggle_special = 1,
        enable_hyprcursor      = true,
        hide_on_touch          = true,
        hide_on_tablet         = true,
        use_cpu_buffer         = 2,
        warp_back_after_non_mouse_input = true,
    },

    decoration = {
        rounding       = 5,
        rounding_power = 2,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },
})

-- Dwindle layout
hl.config({
    dwindle = {
        preserve_split = true,
    },
})

-- Master layout
hl.config({
    master = {
        new_status = "master",
    },
})

-- Scrolling layout
hl.config({
    scrolling = {
        fullscreen_on_one_column = true,
    },
})

----------------
----  MISC  ----
----------------

hl.config({
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo   = false,
    },
})

---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",
        follow_mouse = 1,
        sensitivity = 0,

        touchpad = {
            natural_scroll = false,
        },
    },
})

-- Touchpad gestures
hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

-- Per-device configuration example
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/
-- hl.device({
--     name        = "epic-mouse-v1",
--     sensitivity = -0.1,
-- })

--------------------------------
---- AUTOSTART (optional) ------
--------------------------------

-- https://wiki.hypr.land/Configuring/Basics/Autostart/
hl.on("hyprland.start", function()
    hl.exec_cmd("waybar -c ~/.config/waybar/config.jsonc -s ~/.config/waybar/style.css")
end)
