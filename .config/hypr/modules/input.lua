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
