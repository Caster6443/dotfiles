local vars = require("variables")

hl.config({
	gestures = {
		-- 2026-10-22 第四轮：250 -> 220，再敏感一点（提交阈值 125px -> 110px）
		-- 如太灵敏回 250/270；如仍嫌长再降到 200
		workspace_swipe_distance = 220,
		workspace_swipe_cancel_ratio = 0.5,
		workspace_swipe_min_speed_to_force = 30,
		workspace_swipe_direction_lock = true,
		workspace_swipe_direction_lock_threshold = 10,
		workspace_swipe_create_new = true,
	},
})

-- 5 指横向滑动切换工作区；四指由 move 独占，避免横滑动作冲突
hl.gesture({ fingers = vars.workspaceSwipeFingers, direction = "horizontal", action = "workspace" })
-- 3 指左右滑动（scrolling 布局）：改用原生 scroll_move，1:1 跟手，
-- 松手由 gestures.scrolling.move_snap_to_grid（默认 true）吸附到列。
if vars.layout == "scrolling" then
	hl.gesture({ fingers = vars.gestureFingers, direction = "horizontal", action = "scroll_move" })
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
