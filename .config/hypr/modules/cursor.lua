hl.config({
    binds = { -- https://wiki.hypr.land/Configuring/Basics/Variables/#binds
        pass_mouse_when_bound = false,              -- If disabled, will not pass the mouse events to apps / dragging windows around if a keybind has been triggered.
        scroll_event_delay = 300,                   -- in ms, how many ms to wait after a scroll event to allow passing another one for the binds.
        workspace_back_and_forth = false,           -- If enabled, an attempt to switch to the currently focused workspace will instead switch to the previous workspace. Akin to i3's auto_back_and_forth.
        hide_special_on_workspace_change = false,   -- If enabled, changing the active workspace (including to itself) will hide the special workspace on the monitor where the newly active workspace resides.
        allow_workspace_cycles = false,             -- If enabled, workspaces don’t forget their previous workspace, so cycles can be created by switching to the first workspace in a sequence, then endlessly going to the previous workspace.
        workspace_center_on = 0,                    -- Whether switching workspaces should center the cursor on the workspace (0) or on the last active window for that workspace (1)
        focus_preferred_method = 0,                 -- sets the preferred focus finding method when using hl.dsp.focus({ direction })/hl.dsp.window.move({ direction })/etc. 0 - history (recent have priority), 1 - length (longer shared edges have priority)
        ignore_group_lock = false,                  -- If enabled, dispatchers like hl.dsp.window.move({ into_group }) and hl.dsp.window.move({ out_of_group }) will ignore lock per group
        movefocus_cycles_fullscreen = false,        -- If enabled, when on a fullscreen window, hl.dsp.focus({ direction }) will cycle fullscreen, if not, it will move the focus in a direction.
        movefocus_cycles_groupfirst = false,        -- If enabled, when in a grouped window, hl.dsp.focus({ direction }) will cycle windows in the groups first, then at each ends of tabs, it’ll move on to other windows/groups
        window_direction_monitor_fallback = true,   -- If enabled, moving a window or focus over the edge of a monitor with a direction will move it to the next monitor in that direction.
        disable_keybind_grabbing = false,           -- If enabled, apps that request keybinds to be disabled (e.g. VMs) will not be able to do so.
        allow_pin_fullscreen = false,               -- If enabled, Allow fullscreen to pinned windows, and restore their pinned status afterwards
        drag_threshold = 0,                         -- Movement threshold in pixels for window dragging and c/g bind flags. 0 to disable and grab on mousedown.
    },

    cursor = { -- https://wiki.hypr.land/Configuring/Basics/Variables/#cursor
        invisible = false,                          -- don’t render cursors
        sync_gsettings_theme = true,                -- sync xcursor theme with gsettings, it applies cursor-theme and cursor-size on theme load to gsettings making most CSD gtk based clients use same xcursor theme and size.
        no_hardware_cursors = 2,                    -- disables hardware cursors. 0 - use hw cursors if possible, 1 - don’t use hw cursors, 2 - auto (disable when tearing)
        no_break_fs_vrr = 2,                        -- disables scheduling new frames on cursor movement for fullscreen apps with VRR enabled to avoid framerate spikes (may require no_hardware_cursors = true) 0 - off, 1 - on, 2 - auto (on with content type ‘game’)
        min_refresh_rate = 24,                      -- minimum refresh rate for cursor movement when no_break_fs_vrr is active. Set to minimum supported refresh rate or higher
        hotspot_padding = 0,                        -- the padding, in logical px, between screen edges and the cursor
        inactive_timeout = 333,                     -- In seconds, after how many seconds of cursor’s inactivity to hide it. Set to 0 for never.
        no_warps = false,                           -- If true, will not warp the cursor in many cases (focusing, keybinds, etc)
        persistent_warps = true,                    -- When a window is refocused, the cursor returns to its last position relative to that window, rather than to the centre.
        warp_on_change_workspace = 0,               -- Move the cursor to the last focused window after changing the workspace. Options: 0 (Disabled), 1 (Enabled), 2 (Force - ignores cursor:no_warps option)
        warp_on_toggle_special = 1,                 -- Move the cursor to the last focused window when toggling a special workspace. Options: 0 (Disabled), 1 (Enabled), 2 (Force - ignores cursor:no_warps option)
        default_monitor = "",                       -- the name of a default monitor for the cursor to be set to on startup (see hyprctl monitors for names)
        zoom_factor = 1.0,                          -- the factor to zoom by around the cursor. Like a magnifying glass. Minimum 1.0 (meaning no zoom)
        zoom_rigid = false,                         -- whether the zoom should follow the cursor rigidly (cursor is always centered if it can be) or loosely
        zoom_detached_camera = true,                -- detach the camera from the mouse when zoomed in, only ever moving the camera to keep the mouse in view when it goes past the screen edges
        enable_hyprcursor = true,                   -- whether to enable hyprcursor support
        hide_on_key_press = false,                  -- Hides the cursor when you press any key until the mouse is moved.
        hide_on_touch = true,                       -- Hides the cursor when the last input was a touch input until a mouse input is done.
        hide_on_tablet = true,                      -- Hides the cursor when the last input was a tablet input until a mouse input is done.
        use_cpu_buffer = 2,                         -- Makes HW cursors use a CPU buffer. Required on Nvidia to have HW cursors. 0 - off, 1 - on, 2 - auto (nvidia only)
        warp_back_after_non_mouse_input = true,     -- Warp the cursor back to where it was after using a non-mouse input to move it, and then returning back to mouse.
        zoom_disable_aa = false,                    -- disable antialiasing when zooming, which means things will be pixelated instead of blurry
    },
})

-- Cursor
hl.env("XCURSOR_THEME", "Banana")
hl.env("XCURSOR_SIZE", "60")
hl.env("HYPRCURSOR_THEME", "Banana")
hl.env("HYPRCURSOR_SIZE", "60")
hl.env("WLR_NO_HARDWARE_CURSORS", "1")

-- Toolkit backend
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")

-- XDG
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- Qt
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
