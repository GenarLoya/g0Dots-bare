-- Window rules
-- https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- Suppress maximize events from all apps
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix XWayland dragging issues
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

-- Hyprland-run windowrule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move  = "20 monitor_h-120",
    float = true,
})

-- Satty (anotador de capturas): flotante, centrado y al 70% de la pantalla
hl.window_rule({
    name   = "satty-float-center",
    match  = { class = "com.gabm.satty" },
    float  = true,
    center = true,
    size   = { "monitor_w * 0.7", "monitor_h * 0.7" },
})

-- Picture-in-Picture window
hl.window_rule({
    name        = "pip-window",
    match       = { title = "Picture in picture" },
    float       = true,
    pin         = true,
    size        = {480, 270},
    move        = {"monitor_w-500", "monitor_h-290"},
    border_size = 0,
    no_blur     = true,
    rounding    = 10,
    opacity     = "1.0 override 1.0 override",
})
