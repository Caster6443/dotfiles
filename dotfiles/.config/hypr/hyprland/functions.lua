local function wsaction(action, range, i)
    return function()
        local activews = hl.get_active_workspace()
        if not activews then return end

        local id = activews.id
        if type(id) ~= "number" or id < 1 then
            -- Named workspaces have no numbered group, fall back to the first one.
            id = 1
        end

        local slot  = (id - 1) % 10 + 1
        local z     = range == "group" and ((i - 1) * 10 + slot) or (math.floor((id - 1) / 10) * 10 + i)

        if action == "move" then
            return hl.dispatch(hl.dsp.window.move({ workspace = z }))
        elseif action == "move_silent" then
            return hl.dispatch(hl.dsp.window.move({ workspace = z, follow = false }))
        else
            return hl.dispatch(hl.dsp.focus({ workspace = z }))
        end
    end
end

local function resize_by_screen(x, y)
    local screen = hl.get_active_monitor()
    if screen and type(screen.width) == "number" and type(screen.height) == "number" then
        if not (x == 0 and y == 0) then
            local w = (x and x > 0) and math.floor(screen.width * x / 100) or screen.width
            local h = (y and y > 0) and math.floor(screen.height * y / 100) or screen.height
            return { x = w, y = h, relative = false }
        end
    end
end

local function resize_active_window(x, y)
    return function() -- returning the function so hl reloads everytime correctly
        local win = hl.get_active_window()
        if win and win.size then
            local w = (win.size.x * (x / 100)) or 800
            local h = (win.size.y * (y / 100)) or 600

            hl.dispatch(hl.dsp.window.resize({ x = w, y = h, relative = true }))
        else
            hl.dispatch(hl.dsp.no_op())
        end
    end
end

local function resizer(window, val_fn, x_percent, y_percent, actions)
    if window and val_fn(window) then
        local disp = (type(actions) == "table") and actions or { actions }
        for _, x in ipairs(disp) do
            hl.dispatch(x)
        end

        -- Target the matched window explicitly. Without window=, resize/set_prop
        -- act on the currently focused window instead, mangling whatever tiled
        -- window happened to be focused when this matched.
        local sz = resize_by_screen(x_percent, y_percent)
        if sz then
            sz.window = window
            hl.dispatch(hl.dsp.window.resize(sz))
        end
    end
end

local function move_actions(win)
    local screen = hl.get_active_monitor()

    if screen and screen.width and screen.height and win and win.size then
        local monitor_height = screen.height / screen.scale
        local monitor_width  = screen.width / screen.scale

        local scale_factor   = (monitor_height / 4) / win.size.y

        local target_width   = win.size.x * scale_factor
        local target_height  = win.size.y * scale_factor

        local x_resize       = math.floor(math.max(200, target_width))
        local y_resize       = math.floor(math.max(150, target_height))

        local offset         = math.min(monitor_width, monitor_height) * 0.03

        local move_x         = math.floor(screen.x + monitor_width - x_resize - offset)
        local move_y         = math.floor(screen.y + monitor_height - y_resize - offset)

        return {
            hl.dsp.window.resize({ x = x_resize, y = y_resize, window = win }),
            hl.dsp.window.move({ x = move_x, y = move_y, relative = false, window = win }),
            hl.dsp.window.set_prop({ prop = "keep_aspect_ratio", value = "true", window = win }),
        }
    end
end

return {
    resizer              = resizer,
    resize_by_screen     = resize_by_screen,
    resize_active_window = resize_active_window,
    wsaction             = wsaction,
    move_actions         = move_actions,
}
