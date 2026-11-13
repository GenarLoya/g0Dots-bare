--------------------------------
---- AUTOSTART ------
--------------------------------

-- https://wiki.hypr.land/Configuring/Basics/Autostart/
hl.on("hyprland.start", function()
    hl.exec_cmd("waybar -c ~/.config/waybar/config.jsonc -s ~/.config/waybar/style.css")
    hl.exec_cmd("~/.config/hypr/scripts/start-graphical-session.sh")
    hl.exec_cmd("awww-daemon")
    -- Vicinae: launcher + gestor del clipboard (Wayland nativo, data-control-v1).
    hl.exec_cmd("vicinae server")
    hl.exec_cmd("sleep 2 && ~/.config/hypr/scripts/random-wallpaper.sh")
end)
