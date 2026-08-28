local vars = require("variables")

----------------------
---- Window rules ----
----------------------

hl.window_rule({ match = { fullscreen = false }, opacity = vars.windowOpacity .. " override" })

hl.window_rule({ match = { float = true, xwayland = false }, center = true }) -- Center all floating windows (not xwayland cause popups)

-- Floating Applications
hl.window_rule({
	match = {
		-- xdg-desktop-portal-gtk：GTK 门户文件/文件夹选择对话框（如 Obsidian「打开本地仓库」），任何应用弹的都该浮动
		class = "guifetch|yad|zenity|wev|org.gnome.FileRoller|file-roller|blueman-manager|com.github.GradienceTeam.Gradience|feh|imv|system-config-printer|org.quickshell|xdg-desktop-portal-gtk",
	},
	tag = "+float",
})
hl.window_rule({
	match = {
		title = "(Select|Open)( a)? (File|Folder)(s)?|File (Operation|Upload)( Progress)?|.* Properties|Export Image as PNG|GIMP Crash Debug|Save As|Library",
	},
	tag = "+float",
})
hl.window_rule({ match = { class = "steam", title = "Friends List" }, tag = "+float" })
hl.window_rule({ match = { class = "com-atlauncher-App", title = "ATLauncher Console" }, tag = "+float" })
hl.window_rule({ match = { class = "PandoraLauncher", title = "Minecraft Game Output" }, tag = "+float" })

hl.window_rule({ match = { tag = "float" }, float = true })

-- Opaque Apps (Terminal, Image Viewers, Creative Software, Games) as they prefer native transparency as required
hl.window_rule({
	match = {
		class = "foot|equibop|org.quickshell|imv|swappy|krita|gimp|inkscape|darktable|resolve|kdenlive|shotcut|blender|godot|(steam_app_(default|[0-9]+))|gamescope",
	},
	tag = "+opaque_app",
})

hl.window_rule({ match = { tag = "opaque_app" }, opaque = true })

-- Sized & Centered Floaters
hl.window_rule({ match = { class = "foot", title = "nmtui" }, tag = "+float_70_60" })
hl.window_rule({ match = { class = "org.pulseaudio.pavucontrol|yad-icon-browser" }, tag = "+float_70_60" })
hl.window_rule({ match = { class = "org.gnome.Settings" }, tag = "+float_80_70" })
hl.window_rule({ match = { class = "nwg-look" }, tag = "+float_60_50" })

-- 选择工作区目录对话框：浮动 + 居中 + 适中尺寸
hl.window_rule({
	match = { title = "^Select Workspace Directory$" },
	float = true,
	size = "(monitor_w*0.7) (monitor_h*0.6)",
	center = true,
})

-- QQ聊天记录窗口（私聊/群聊，title 形如"xxx的聊天记录"）：浮动 + 居中 + 适中尺寸
hl.window_rule({
	match = { class = "QQ", title = ".*的聊天记录.*" },
	float = true,
	size = "(monitor_w*0.5) (monitor_h*0.8)",
	center = true,
})

-- Obsidian 1.13+ 设置独立窗口（标题形如"设置/Settings - 库名 - Obsidian"）：浮动 + 居中
-- class 兼容旧版 obsidian 与 1.13 起的 md.obsidian / md.Obsidian
hl.window_rule({
	match = {
		class = "^(obsidian|md\\.obsidian|md\\.Obsidian|md\\.obsidian\\.Obsidian)$",
		title = ".*(设置|Settings).*",
	},
	float = true,
	center = true,
})

-- 微信查看图片和视频：浮动 + 居中 + 适中尺寸
hl.window_rule({
	match = { title = "^图片和视频$", class = "wechat" },
	float = true,
	--size = "(monitor_w*0.5) (monitor_h*0.5)",
	center = true,
})

-- Thunar 打开图片（GNOME Loupe）与视频（mpv）：浮动 + 居中
hl.window_rule({
	match = { class = "org.gnome.Loupe|loupe" },
	float = true,
	center = true,
})
hl.window_rule({
	match = { class = "mpv" },
	float = true,
	center = true,
})

-- 修复虚拟系统管理器总是默认在1号工作区打开
hl.window_rule({ match = { class = "virt-manager" }, workspace = "unset" })

hl.window_rule({
	match = { tag = "float_70_60" },
	float = true,
	size = "(monitor_w*0.7) (monitor_h*0.6)",
	center = true,
})
hl.window_rule({
	match = { tag = "float_80_70" },
	float = true,
	size = "(monitor_w*0.8) (monitor_h*0.7)",
	center = true,
})
hl.window_rule({
	match = { tag = "float_60_50" },
	float = true,
	size = "(monitor_w*0.6) (monitor_h*0.5)",
	center = true,
})

-- Games (Steam, Lutris/Wine, Gamescope)
hl.window_rule({
	match = { class = "(steam_app_(default|[0-9]+))|gamescope" },
	immediate = true,
	idle_inhibit = "always",
})

-- Steam
hl.window_rule({ match = { class = "steam" }, rounding = 10 })

-- Cheatsheet：半透明 + 模糊（放在末尾覆盖 opaque_app 规则）
-- 重开（visible false→true）时客户端会异步请求 maximized，导致铺满工作区；
-- 用 fullscreen_state 在 map 时清零 + size/center 强制 72% 居中兜底。
hl.window_rule({
	match = { title = "^cheatsheet$" },
	float = true,
	size = "(monitor_w*0.72) (monitor_h*0.72)",
	center = true,
	opaque = false,
	opacity = "0.92 override",
	-- 重开时客户端会异步请求 maximized，这里在 map 时强制 internal/client 全屏态都为 0
	fullscreen_state = "0 0",
	-- 窗口本体从顶部滑入，内容随窗口整体移动（内容层不再自己做动画）
	animation = "slide top",
})

-- Picture in picture (resize and move done via script)
hl.window_rule({
	match = { title = "Picture(-| )in(-| )[Pp]icture" },
	move = "(monitor_w-(window_w*0.2)) (monitor_h-(window_h*0.3))",
	pin = true,
	float = true,
	keep_aspect_ratio = true,
})

-- Ueberzugpp
hl.window_rule({ match = { class = "^(ueberzugpp_.*)$" }, float = true, no_initial_focus = true })

-- Autodesk Fusion 360
hl.window_rule({ match = { class = "fusion360.exe", title = "Fusion360|(Marking Menu)" }, no_blur = true })

-- Ugh xwayland popups
hl.window_rule({ match = { xwayland = true, title = "win[0-9]+" }, no_dim = true, no_shadow = true, rounding = 10 })

-- Special workspaces
hl.window_rule({ match = { class = "btop" }, workspace = "special:sysmon" })
hl.window_rule({
	match = {
		class = "feishin|Spotify|Supersonic|Cider|com.github.th_ch.youtube_music|Plexamp|com-maxrave-simpmusic-MainKt",
	},
	workspace = "special:music",
})
hl.window_rule({ match = { initial_title = "Spotify( %(?Free%)?)?" } }) -- Spotify wayland, it has no class for some reason
hl.window_rule({ match = { class = "discord|equibop|vesktop|whatsapp" }, workspace = "special:communication" })
hl.window_rule({ match = { class = "Todoist" }, workspace = "special:todo" })

-------------------------
---- Workspace rules ----
-------------------------

hl.workspace_rule({ workspace = "w[tv1]s[false]", gaps_out = vars.singleWindowGapsOut })
hl.workspace_rule({ workspace = "f[1]s[false]", gaps_out = vars.singleWindowGapsOut })

---------------------
---- Layer rules ----
---------------------

hl.layer_rule({ match = { namespace = "hyprpicker" }, animation = "fade" }) -- Colour picker out animation
hl.layer_rule({ match = { namespace = "logout_dialog" }, animation = "fade" }) -- wlogout
hl.layer_rule({ match = { namespace = "selection" }, animation = "fade" }) -- slurp
hl.layer_rule({ match = { namespace = "wayfreeze" }, animation = "fade" }) -- wayfreeze
hl.layer_rule({ match = { namespace = "launcher" }, animation = "popin 80%", blur = true }) -- Fuzzel

-- Shell
hl.layer_rule({ match = { namespace = "caelestia-(border-exclusion|area-picker)" }, no_anim = true })
hl.layer_rule({ match = { namespace = "caelestia-(drawers|background)" }, animation = "fade" })

-- Terminal
hl.window_rule({ match = { class = "foot" }, no_blur = true })

-- QQ
hl.window_rule({
	match = { title = "图片查看器" },
	float = true,
	center = true,
	--size = "100, 50",
	animation = "popin",
})
