local vars = require("variables")
local fn = require("hyprland.functions")

-- ============================================================
-- Launcher（Super 打断）
-- 设计：在 Hyprland 侧用一个状态位跟踪「Super 按住期间是否按过
-- 其他键/鼠标」，松开 Super 时只有状态为「干净」才派发 launcher
-- 事件。不再依赖 catchall（0.55+ Lua 下仅 submap 内可用，顶层注册
-- 会被静默降级为普通键）和 Quickshell 侧的计数时序，因此不受事件
-- 顺序影响。
-- ============================================================
local superLauncherBlocked = false

-- 键盘：按住 Super 期间按下任意非 Super 键 -> 标记打断
hl.on("input.keyboard.key", function(keycode, _, event)
	if event ~= 1 then
		return -- 只处理按下（0=释放, 1=按下, 2=重复）
	end
	if keycode == 133 or keycode == 134 then -- SUPER_L / SUPER_R
		superLauncherBlocked = false
	elseif hl.is_key_down(133) or hl.is_key_down(134) then
		superLauncherBlocked = true
	end
end)

-- 鼠标：Super + 鼠标按键/滚轮 -> 同样标记打断（保持 non_consuming，不抢原有功能）
for _, btn in ipairs({ "mouse:272", "mouse:273", "mouse:274", "mouse:275", "mouse:276", "mouse:277" }) do
	hl.bind("SUPER + " .. btn, function() superLauncherBlocked = true end, { non_consuming = true })
end
for _, combo in ipairs({
	"SUPER + mouse_up", "SUPER + mouse_down",
	"CTRL + SUPER + mouse_up", "CTRL + SUPER + mouse_down",
	"SUPER + ALT + mouse_up", "SUPER + ALT + mouse_down",
}) do
	hl.bind(combo, function() superLauncherBlocked = true end, { non_consuming = true })
end

-- 启动器：仅当 Super 是干净地单独按下时触发
hl.bind("SUPER + SUPER_L", function()
	if not superLauncherBlocked then
		hl.dispatch(hl.dsp.global("caelestia:launcher"))
	end
	superLauncherBlocked = false
end, { release = true, description = "程序启动器" })

-- Cheatsheet (in-shell module, toggled via caelestia IPC)
hl.bind(vars.kbCheatsheet, hl.dsp.exec_cmd("qs -c caelestia ipc call cheatsheet toggle"), { description = "快捷键速查" })

-- Misc
hl.bind(vars.kbSession, hl.dsp.global("caelestia:session"), { description = "会话面板" })
hl.bind(vars.kbShowSidebar, hl.dsp.global("caelestia:sidebar"), { description = "侧边栏" })
hl.bind(vars.kbClearNotifs, hl.dsp.global("caelestia:clearNotifs"), { locked = true, description = "清除通知" })
hl.bind(vars.kbShowPanels, hl.dsp.global("caelestia:showall"), { description = "显示所有面板" })
hl.bind(vars.kbLock, hl.dsp.global("caelestia:lock"), { description = "锁屏" })

-- Restore lock
hl.bind(vars.kbRestoreLock, function()
	hl.dispatch(hl.dsp.exec_cmd("caelestia shell -d"))
	hl.dispatch(hl.dsp.global("caelestia:lock"))
end)

-- Brightness
hl.bind("XF86MonBrightnessUp", hl.dsp.global("caelestia:brightnessUp"), { locked = true, description = "提高亮度" })
hl.bind("XF86MonBrightnessDown", hl.dsp.global("caelestia:brightnessDown"), { locked = true, description = "降低亮度" })

-- Media
hl.bind("CTRL + SUPER + Space", hl.dsp.global("caelestia:mediaToggle"), { locked = true, description = "播放/暂停" })
hl.bind("XF86AudioPlay", hl.dsp.global("caelestia:mediaToggle"), { locked = true, description = "播放/暂停" })
hl.bind("XF86AudioPause", hl.dsp.global("caelestia:mediaToggle"), { locked = true, description = "播放/暂停" })
hl.bind("CTRL + SUPER + Equal", hl.dsp.global("caelestia:mediaNext"), { locked = true, description = "下一曲" })
hl.bind("XF86AudioNext", hl.dsp.global("caelestia:mediaNext"), { locked = true, description = "下一曲" })
hl.bind("CTRL + SUPER + Minus", hl.dsp.global("caelestia:mediaPrev"), { locked = true, description = "上一曲" })
hl.bind("XF86AudioPrev", hl.dsp.global("caelestia:mediaPrev"), { locked = true, description = "上一曲" })
hl.bind("XF86AudioStop", hl.dsp.global("caelestia:mediaStop"), { locked = true, description = "停止" })

-- Kill/restart
hl.bind("CTRL + SUPER + SHIFT + R", hl.dsp.exec_cmd("qs -c caelestia kill"), { release = true, description = "重启 caelestia" })
hl.bind(
	"CTRL + SUPER + ALT + R",
	hl.dsp.exec_cmd("qs -c caelestia kill; sleep .1; caelestia shell -d"),
	{ release = true, description = "重启 caelestia（强）" }
)

-- Workspaces（数字键 1-10）
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(vars.kbGoToWs .. " + " .. key, fn.wsaction("focus", "", i), { description = "切换到 1-10 号工作区" })
	hl.bind(vars.kbMoveWinToWs .. " + " .. key, fn.wsaction("move", "", i), { description = "移动窗口到 1-10 号工作区" })
	hl.bind(vars.kbGoToWsGroup .. " + " .. key, fn.wsaction("focus", "group", i), { description = "切换到 1-10 号工作区组" })
	hl.bind(vars.kbMoveWinToWsGroup .. " + " .. key, fn.wsaction("move", "group", i), { description = "移动窗口到 1-10 号工作区组" })
end

-- Go to workspace -1/+1
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "-1" }))
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "+1" }))
hl.bind(vars.kbPrevWs, hl.dsp.focus({ workspace = "-1" }), { repeating = true, description = "上一个工作区" })
hl.bind(vars.kbNextWs, hl.dsp.focus({ workspace = "+1" }), { repeating = true, description = "下一个工作区" })
hl.bind("SUPER + Page_Up", hl.dsp.focus({ workspace = "-1" }), { repeating = true })
hl.bind("SUPER + Page_down", hl.dsp.focus({ workspace = "+1" }), { repeating = true })

-- Go to workspace group -1/+1
hl.bind("CTRL + SUPER + mouse_down", hl.dsp.focus({ workspace = "-10" }))
hl.bind("CTRL + SUPER + mouse_up", hl.dsp.focus({ workspace = "+10" }))

-- Move window to workspace -1/+1
hl.bind("SUPER + ALT + Page_Up", hl.dsp.window.move({ workspace = "-1" }), { repeating = true, description = "移动窗口到上一个工作区" })
hl.bind("SUPER + ALT + Page_Down", hl.dsp.window.move({ workspace = "+1" }), { repeating = true, description = "移动窗口到下一个工作区" })
hl.bind("SUPER + ALT + mouse_down", hl.dsp.window.move({ workspace = "-1" }))
hl.bind("SUPER + ALT + mouse_up", hl.dsp.window.move({ workspace = "+1" }))
hl.bind("CTRL + SUPER + SHIFT + right", hl.dsp.window.move({ workspace = "+1" }), { repeating = true })
hl.bind("CTRL + SUPER + SHIFT + left", hl.dsp.window.move({ workspace = "-1" }), { repeating = true })

-- Move window to/from special workspace
hl.bind("CTRL + SUPER + SHIFT + up", hl.dsp.window.move({ workspace = "special:special" }))
hl.bind("CTRL + SUPER + SHIFT + down", hl.dsp.window.move({ workspace = "e+0" }), { description = "移动窗口出特殊工作区" })
hl.bind("SUPER + ALT + S", hl.dsp.window.move({ workspace = "special:special" }), { description = "移动窗口到特殊工作区" })

-- Window groups
hl.bind(vars.kbWindowGroupCycleNext, hl.dsp.window.cycle_next(), { repeating = true, description = "切换到下一个窗口" })
hl.bind(vars.kbWindowGroupCyclePrev, hl.dsp.window.cycle_next(), { repeating = true, description = "切换到上一个窗口" })
hl.bind("CTRL + ALT + Tab", hl.dsp.group.next(), { repeating = true })
hl.bind("CTRL + SHIFT + ALT + Tab", hl.dsp.group.prev(), { repeating = true })
hl.bind(vars.kbToggleGroup, hl.dsp.group.toggle(), { description = "切换分组" })
hl.bind(vars.kbUngroup, hl.dsp.window.move({ out_of_group = true }), { description = "取消分组" })
hl.bind("SUPER + SHIFT + Comma", hl.dsp.group.lock_active(), { description = "锁定/解锁分组" })

-- Window actions
hl.bind("SUPER + left", hl.dsp.focus({ direction = "left" }), { description = "聚焦左侧窗口" })
hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }), { description = "聚焦右侧窗口" })
hl.bind("SUPER + up", hl.dsp.focus({ direction = "up" }), { description = "聚焦上方窗口" })
hl.bind("SUPER + down", hl.dsp.focus({ direction = "down" }), { description = "聚焦下方窗口" })
hl.bind("SUPER + SHIFT + left", hl.dsp.window.move({ direction = "left" }), { description = "窗口左移" })
hl.bind("SUPER + SHIFT + right", hl.dsp.window.move({ direction = "right" }), { description = "窗口右移" })
hl.bind("SUPER + SHIFT + up", hl.dsp.window.move({ direction = "up" }), { description = "窗口上移" })
hl.bind("SUPER + SHIFT + down", hl.dsp.window.move({ direction = "down" }), { description = "窗口下移" })
hl.bind("SUPER + Minus", hl.dsp.window.resize(fn.resize_active_window(-10, 0)), { repeating = true, description = "窗口变窄" })
hl.bind("SUPER + Equal", hl.dsp.window.resize(fn.resize_active_window(10, 0)), { repeating = true, description = "窗口变宽" })
hl.bind("SUPER + SHIFT + Minus", hl.dsp.window.resize(fn.resize_active_window(0, -10)), { repeating = true, description = "窗口变矮" })
hl.bind("SUPER + SHIFT + Equal", hl.dsp.window.resize(fn.resize_active_window(0, 10)), { repeating = true, description = "窗口变高" })
hl.bind("SUPER + ALT + left", hl.dsp.window.resize(fn.resize_active_window(-10, 0)), { repeating = true })
hl.bind("SUPER + ALT + right", hl.dsp.window.resize(fn.resize_active_window(10, 0)), { repeating = true })
hl.bind("SUPER + ALT + up", hl.dsp.window.resize(fn.resize_active_window(0, -10)), { repeating = true })
hl.bind("SUPER + ALT + down", hl.dsp.window.resize(fn.resize_active_window(0, 10)), { repeating = true })

-- 鼠标滚轮横向切换窗口聚焦
hl.bind("SHIFT + mouse_down", hl.dsp.layout("move +col"))
hl.bind("SHIFT + mouse_up", hl.dsp.layout("move -col"))

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(vars.kbMoveWindow, hl.dsp.window.drag(), { mouse = true, description = "拖动窗口" })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind(vars.kbResizeWindow, hl.dsp.window.resize(), { mouse = true, description = "调整窗口大小" })
hl.bind("CTRL + SUPER + Backslash", hl.dsp.window.center(), { description = "窗口居中" })
hl.bind("CTRL + SUPER + ALT + Backslash", hl.dsp.window.resize(fn.resize_by_screen(55, 70)))
hl.bind("CTRL + SUPER + ALT + Backslash", hl.dsp.window.center())
hl.bind(vars.kbWindowPip, function()
	local a = hl.get_active_window()
	if a then
		local pip = fn.move_actions(a) or {}
		table.insert(pip, 1, hl.dsp.window.float())
		table.insert(pip, hl.dsp.window.pin({ window = "address:" .. a.address }))

		for _, x in ipairs(pip) do
			hl.dispatch(x)
		end
	end
end, { description = "画中画（悬浮置顶）" })
hl.bind(vars.kbPinWindow, hl.dsp.window.pin(), { description = "固定/取消固定窗口" })
hl.bind(vars.kbWindowFullscreen, hl.dsp.window.fullscreen({ mode = "fullscreen" }), { description = "全屏" })
hl.bind(vars.kbWindowBorderedFullscreen, hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }), { description = "无边框全屏" })
hl.bind(vars.kbToggleWindowFloating, hl.dsp.window.float(), { description = "切换浮动" })
hl.bind(vars.kbCloseWindow, hl.dsp.window.close(), { description = "关闭窗口" })

-- Special workspace toggles
hl.bind(vars.kbSpecialWs, hl.dsp.exec_cmd("caelestia toggle specialws"), { description = "特殊工作区" })
hl.bind(vars.kbSystemMonitorWs, hl.dsp.exec_cmd("caelestia toggle sysmon"), { description = "系统监控工作区" })
hl.bind(vars.kbMusicWs, hl.dsp.exec_cmd("caelestia toggle music"), { description = "音乐工作区" })
hl.bind(vars.kbCommunicationWs, hl.dsp.exec_cmd("caelestia toggle communication"), { description = "通讯工作区" })
hl.bind(vars.kbTodoWs, hl.dsp.exec_cmd("caelestia toggle todo"), { description = "待办工作区" })
hl.bind(vars.kbProxy, hl.dsp.exec_cmd("caelestia toggle proxy"), { description = "代理工作区" })

-- Apps
hl.bind(vars.kbTerminal, hl.dsp.exec_cmd(vars.terminal), { description = "终端" })
hl.bind(vars.kbBrowser, hl.dsp.exec_cmd(vars.browser), { description = "浏览器" })
hl.bind(vars.kbEditor, hl.dsp.exec_cmd(vars.editor), { description = "编辑器" })
hl.bind(vars.kbFileExplorer, hl.dsp.exec_cmd(vars.fileExplorer), { description = "文件管理器" })
hl.bind("CTRL + ALT + V", hl.dsp.exec_cmd(vars.audioSettings))
hl.bind("SUPER + O", hl.dsp.exec_cmd("obsidian"), { description = "Obsidian" })

-- Utilities
hl.bind("Print", hl.dsp.exec_cmd("caelestia screenshot"), { locked = true, description = "截图" })
hl.bind("SUPER + SHIFT + S", hl.dsp.global("caelestia:screenshotFreezeClip"), { description = "区域截图并复制到剪贴板（冻结画面）" })
hl.bind("ALT + SHIFT + S", hl.dsp.global("caelestia:screenshotFreeze"), { description = "截图并编辑" })
hl.bind("SUPER + ALT + R", hl.dsp.exec_cmd("caelestia record -s"), { description = "录屏（带声音）" })
hl.bind("CTRL + ALT + R", hl.dsp.exec_cmd("caelestia record"), { description = "录屏" })
hl.bind("SUPER + SHIFT + ALT + R", hl.dsp.exec_cmd("caelestia record -r"), { description = "录屏（区域）" })
hl.bind("SUPER + ALT + P", hl.dsp.exec_cmd("caelestia record -p"), { description = "录屏暂停/继续" })
hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a"), { description = "取色器" })

-- Volume
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, description = "静音" })
hl.bind("SUPER + SHIFT + M", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, description = "静音" })
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd(
		"wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 0; wpctl set-volume @DEFAULT_AUDIO_SINK@ " .. vars.volumeStep .. "%+"
	),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd(
		"wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 0; wpctl set-volume @DEFAULT_AUDIO_SINK@ " .. vars.volumeStep .. "%-"
	),
	{ locked = true, repeating = true }
)

-- Sleep
hl.bind("SUPER + SHIFT + L", hl.dsp.exec_cmd(vars.sleepGestureCmd), { locked = true, description = "睡眠" })

-- Clipboard and emoji picker
hl.bind("SUPER + V", hl.dsp.exec_cmd("pkill fuzzel || caelestia clipboard"), { description = "剪贴板历史" })
hl.bind("SUPER + ALT + V", hl.dsp.exec_cmd("pkill fuzzel || caelestia clipboard -d"), { description = "剪贴板（删除）" })
hl.bind("SUPER + Period", hl.dsp.exec_cmd("pkill fuzzel || caelestia emoji -p"), { description = "表情选择" })
hl.bind(
	"CTRL + SHIFT + ALT + V",
	hl.dsp.exec_cmd("sleep 0.5s && ydotool type -d 1 '$(cliphist list | head -1 | cliphist decode)"),
	{ locked = true, description = "粘贴剪贴板最后一项" }
)

-- Testing
hl.bind(
	"SUPER + ALT + F12",
	hl.dsp.exec_cmd(
		"notify-send -u low -i dialog-information-symbolic 'Test notification' "
			.. [["Here's a really long message to test truncation and wrapping\nYou can middle click or flick this notification to dismiss it!"]]
			.. " -a 'Shell' -A 'Test1=I got it!' -A 'Test2=Another action'"
	)
)

hl.define_submap("passthru", function()
	hl.bind("SUPER + Escape", hl.dsp.submap("reset"))
end)
hl.bind("SUPER + U", hl.dsp.submap("passthru"))
