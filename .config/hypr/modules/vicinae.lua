-- Vicinae - layer rules
-- https://docs.vicinae.com/quickstart/hyprland-lua
--
-- blur y sin animación para la ventana de Vicinae.

hl.layer_rule({
    match = { namespace = "vicinae" },
    name = "vicinae-blur",
    blur = true,
    ignore_alpha = 0,
})

hl.layer_rule({
    match = { namespace = "vicinae" },
    name = "vicinae-no-anim",
    no_anim = true,
})
