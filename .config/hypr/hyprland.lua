-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- Hyprland Configuration (Lua format - v0.55+)           --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Load modules
require("modules.env")
require("modules.cursor")
require("modules.animations")
require("modules.keybinds")
require("modules.windowrules")
require("modules.workspace_rules")
require("modules.theme")

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

--------------
---- BINDS ----
------------

hl.config({
    binds = {
        movefocus_cycles_fullscreen = true,
    },
})

-------------
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
    hl.exec_cmd("~/.config/hypr/scripts/start-graphical-session.sh")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("sleep 1 && ~/.config/hypr/scripts/random-wallpaper.sh")
end)
