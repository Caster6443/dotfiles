local vars = require("variables")

hl.config({
	animations = {
		enabled = true,
	},
})

-- Animation curves
hl.curve("specialWorkSwitch", { type = "bezier", points = { { 0.05, 0.7 }, { 0.1, 1 } } })
hl.curve("emphasizedAccel", { type = "bezier", points = { { 0.3, 0 }, { 0.8, 0.15 } } })
hl.curve("emphasizedDecel", { type = "bezier", points = { { 0.05, 0.8 }, { 0.1, 1 } } })
hl.curve("standard", { type = "bezier", points = { { 0.2, 0 }, { 0, 1 } } })
hl.curve("fluidSlide", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1.03 } } })
-- 接近 niri horizontal-view-movement 的临界阻尼弹簧（stiffness 500 ≈ niri 配置）
-- 注意：Hyprland 的 spring 字段名是 dampening（不是文档里的 damping）
hl.curve("scrollSpring", { type = "spring", mass = 1, stiffness = 500, dampening = 45 })

-- Animation configs
hl.animation({ leaf = "layersIn", enabled = true, speed = 3, bezier = "emphasizedDecel", style = "slide" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 3, bezier = "emphasizedDecel", style = "slide" })
hl.animation({ leaf = "fadeLayers", enabled = true, speed = 3, bezier = "standard" })

-- hl.animation({ leaf = "windowsIn", enabled = true, speed = 5, bezier = "emphasizedDecel" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3, bezier = "fluidSlide", style = "slide right" })
hl.animation({
	leaf = "windowsOut",
	enabled = true,
	speed = 3,
	bezier = "fluidSlide",
	style = "slide right",
	fade = true,
})
-- hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "emphasizedAccel" })
-- windowsMove 同时驱动 scrolling 布局的视图横移；用弹簧保留速度，
-- 连续 focus 时不会像 bezier 那样每步从零重新缓动。
hl.animation({ leaf = "windowsMove", enabled = true, speed = 3, spring = "scrollSpring" })
-- hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "" })
-- hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "standard", style = "slidevert" })
-- 上下切换工作区（含触摸板手势松手后的收尾）从 300ms 放慢到 400ms
hl.animation({
	leaf = "workspaces",
	enabled = true,
	speed = 4,
	bezier = "standard",
	style = vars.layout == "scrolling" and "slidefadevert 20%" or "slidefade 20%",
})

hl.animation({
	leaf = "specialWorkspace",
	enabled = true,
	speed = 3,
	bezier = "specialWorkSwitch",
	style = "slidefadevert 15%",
})
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "standard" })
hl.animation({ leaf = "fadeDim", enabled = true, speed = 3, bezier = "standard" })
hl.animation({ leaf = "border", enabled = true, speed = 3, bezier = "standard" })
