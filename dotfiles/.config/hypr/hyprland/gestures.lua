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

-- 4 指横向滑动切换工作区
hl.gesture({ fingers = vars.workspaceSwipeFingers, direction = "horizontal", action = "workspace" })
-- 3 指左右滑动滚动窗口列（scrolling 布局原生跟手手势；自然方向：左滑 → 下一列，右滑 → 上一列）
hl.gesture({ fingers = vars.gestureFingers, direction = "horizontal", action = "scroll_move" })
-- 3 指上下滑动切换工作区（内置跟手动画；自然方向：上滑 → 下一个，下滑 → 上一个）
hl.gesture({ fingers = vars.gestureFingers, direction = "vertical", action = "workspace" })
-- 4 指上滑呼出/收起特殊工作区
hl.gesture({ fingers = vars.gestureFingersMore, direction = "up", action = "special", workspace_name = "special" })
-- 4 指下滑休眠
hl.gesture({
	fingers = vars.gestureFingersMore,
	direction = "down",
	action = function()
		hl.exec_cmd(vars.sleepGestureCmd)
	end,
})
