local vars = require("variables")
local fn = require("hyprland.functions")

hl.on("hyprland.start", function()
	-- Keyring and auth
	hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
	hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")

	-- Clipboard history
	hl.exec_cmd("wl-paste --type text --watch cliphist store")
	hl.exec_cmd("wl-paste --type image --watch cliphist store")

	-- Auto delete trash 30 days old
	hl.exec_cmd("trash-empty 30")

	-- Cursors
	hl.exec_cmd("hyprctl setcursor " .. vars.cursorTheme .. " " .. vars.cursorSize)
	hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme " .. vars.cursorTheme)
	hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size " .. vars.cursorSize)

	-- Location provider and night light
	hl.exec_cmd("/usr/lib/geoclue-2.0/demos/agent")
	hl.exec_cmd("sleep 1 && gammastep")

	-- Forward bluetooth media commands to MPRIS
	hl.exec_cmd("mpris-proxy")

	-- Start shell
	hl.exec_cmd("caelestia shell -d")

	-- Wallpaper daemon
	hl.exec_cmd("awww-daemon")

	-- Disable touchpad while typing
	hl.exec_cmd("ydotoold")

	-- input method
	hl.exec_cmd("fcitx5 -d")

	-- Auto switch wallpaper
	hl.exec_cmd("bash -c '~/.config/hypr/scripts/auto_switch_wallpaper.sh &'")
end)

-- Match and resize the event window, never the unrelated focused client.
local function apply_resizer_rules(win)
    local function field_match(field, pattern, plain)
        return function(w)
            return type(w[field]) == "string" and string.find(w[field], pattern, 1, plain)
        end
    end
    local float_center = {
        hl.dsp.window.float({ action = "on", window = win }),
        hl.dsp.window.center({ window = win }),
    }
    fn.resizer(win, field_match("class", "Bitwarden", true), 20, 54, float_center)
    fn.resizer(win, field_match("title", "^Extension: %(Bitwarden Password Manager%) %- Bitwarden", false), 20, 54, float_center)
    fn.resizer(win, field_match("class", "nngceckbapebfimnlniiiahkandclblb", true), 20, 54, float_center)
    fn.resizer(win, field_match("title", "^Picture[- ]in[- ][Pp]icture$", false), 0, 0, fn.move_actions(win) or {})
end
hl.on("window.class", apply_resizer_rules)
hl.on("window.title", apply_resizer_rules)
hl.on("window.open", apply_resizer_rules)
