local vars = require("variables")

hl.config({
	gestures = {
		workspace_swipe_distance = 700,
		workspace_swipe_cancel_ratio = 0.15,
		workspace_swipe_min_speed_to_force = 5,
		workspace_swipe_direction_lock = true,
		workspace_swipe_direction_lock_threshold = 10,
		workspace_swipe_create_new = true,
	},
})

-- 5 指横向滑动切换工作区；四指由 move 独占，避免横滑动作冲突
hl.gesture({ fingers = vars.workspaceSwipeFingers, direction = "horizontal", action = "workspace" })
-- 3 指左右滑动（scrolling 布局）：
--   滑动幅度大（>=120px）→ 切到相邻列并居中；
--   幅度小 → 当前列回到贴边，与相邻列平分桌面（只露两列）。
if vars.layout == "scrolling" then
	local swipe = { total = 0 }

	-- 让当前列回到“贴边 + 相邻列”的平分视图：用两次相反 focus 触发重排，焦点不变
	local function split_view()
		local w = hl.get_active_window()
		if not w or not w.workspace then return end
		local xs = {}
		for _, other in ipairs(hl.get_workspace_windows(w.workspace.id)) do
			xs[#xs + 1] = other.at.x
		end
		table.sort(xs)
		if #xs < 2 then return end
		if w.at.x > xs[1] + 1 then
			hl.dispatch(hl.dsp.layout("focus l"))
			hl.dispatch(hl.dsp.layout("focus r"))
		elseif w.at.x < xs[#xs] - 1 then
			hl.dispatch(hl.dsp.layout("focus r"))
			hl.dispatch(hl.dsp.layout("focus l"))
		end
	end

	hl.gesture({
		fingers = vars.gestureFingers,
		direction = "horizontal",
		action = {
			start = function()
				swipe.total = 0
			end,
			update = function(e)
				swipe.total = swipe.total + e.delta.x
			end,
			finish = function(e)
				if e.cancelled then return end
				if math.abs(swipe.total) >= 120 then
					-- 手指右移 = 内容右移 = 看左侧列
					local dir = swipe.total > 0 and "l" or "r"
					hl.dispatch(hl.dsp.layout("focus " .. dir))
					hl.dispatch(hl.dsp.layout("center"))
				else
					split_view()
				end
			end,
		},
	})
else
	hl.gesture({ fingers = vars.gestureFingers, direction = "horizontal", action = "workspace" })
end
-- 3 指上下滑动切换工作区（内置跟手动画；自然方向：上滑 → 下一个，下滑 → 上一个）
hl.gesture({ fingers = vars.gestureFingers, direction = "vertical", action = "workspace" })
-- 4 指任意方向拖动活动窗口；Hyprland 原生 move 手势会跟随手指移动窗口
hl.gesture({ fingers = 4, direction = "swipe", action = "move" })
-- 5 指上滑呼出/收起特殊工作区
hl.gesture({ fingers = vars.gestureFingersMore, direction = "up", action = "special", workspace_name = "special" })
-- 5 指下滑休眠
hl.gesture({
	fingers = vars.gestureFingersMore,
	direction = "down",
	action = function()
		hl.exec_cmd(vars.sleepGestureCmd)
	end,
})
