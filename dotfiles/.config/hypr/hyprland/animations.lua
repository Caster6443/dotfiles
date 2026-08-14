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

-- Animation configs
hl.animation({ leaf = "layersIn", enabled = true, speed = 5, bezier = "emphasizedDecel", style = "slide" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 4, bezier = "emphasizedDecel", style = "slide" })
hl.animation({ leaf = "fadeLayers", enabled = true, speed = 5, bezier = "standard" })

-- hl.animation({ leaf = "windowsIn", enabled = true, speed = 5, bezier = "emphasizedDecel" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 6, bezier = "fluidSlide", style = "slide right" })
hl.animation({
	leaf = "windowsOut",
	enabled = true,
	speed = 6,
	bezier = "fluidSlide",
	style = "slide right",
	fade = true,
})
-- hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "emphasizedAccel" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 6, bezier = "standard" })
-- hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "" })
-- hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "standard", style = "slidevert" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "standard", style = "slidefadevert 20%" })

hl.animation({
	leaf = "specialWorkspace",
	enabled = true,
	speed = 4,
	bezier = "specialWorkSwitch",
	style = "slidefadevert 15%",
})
hl.animation({ leaf = "fade", enabled = true, speed = 6, bezier = "standard" })
hl.animation({ leaf = "fadeDim", enabled = true, speed = 6, bezier = "standard" })
hl.animation({ leaf = "border", enabled = true, speed = 6, bezier = "standard" })
