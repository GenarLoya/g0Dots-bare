--------------
---- BINDS ----
--------------

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
        movefocus_cycles_fullscreen = true,        -- If enabled, when on a fullscreen window, hl.dsp.focus({ direction }) will cycle fullscreen, if not, it will move the focus in a direction.
        movefocus_cycles_groupfirst = false,        -- If enabled, when in a grouped window, hl.dsp.focus({ direction }) will cycle windows in the groups first, then at each ends of tabs, it’ll move on to other windows/groups
        window_direction_monitor_fallback = true,   -- If enabled, moving a window or focus over the edge of a monitor with a direction will move it to the next monitor in that direction.
        disable_keybind_grabbing = false,           -- If enabled, apps that request keybinds to be disabled (e.g. VMs) will not be able to do so.
        allow_pin_fullscreen = false,               -- If enabled, Allow fullscreen to pinned windows, and restore their pinned status afterwards
        drag_threshold = 0,                         -- Movement threshold in pixels for window dragging and c/g bind flags. 0 to disable and grab on mousedown.
    },
})
