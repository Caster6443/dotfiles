local home = os.getenv("HOME")
local hypr = home .. "/.config/hypr"
package.path = package.path .. ";" .. home .. "/.config/caelestia/?.lua"

-- Create a file if it doesn't exist, optionally with initial content
local function maybe_create(file, content)
	local f = io.open(file)

	if f then
		f:close()
		return
	end

	f = io.open(file, "w")
	if f then
		if content then
			f:write(content)
		end
		f:close()
	end
end

-- Copy src to dst, but only if dst doesn't already exist
local function maybe_copy(src, dst)
	local out = io.open(dst)
	if out then
		out:close()
		return
	end

	local input = io.open(src, "r")
	if not input then
		return
	end

	out = io.open(dst, "w")
	if out then
		out:write(input:read("*a"))
		out:close()
	end
	input:close()
end

-- Maybe set current colours to defaults
maybe_copy(hypr .. "/scheme/default.lua", hypr .. "/scheme/current.lua")

-- User variables
maybe_create(home .. "/.config/caelestia/hypr-vars.lua", "return {}\n")
local overrides = require("hypr-vars")
if type(overrides) == "table" then
	local vars = require("variables")
	for k, v in pairs(overrides) do
		vars[k] = v
	end
end

-- Default monitor conf
-- 用 desc:（EDID 描述前缀）代替 DRM 连接器名（eDP-N / DP-N）：
--   连接器编号由内核「按类型全局编号池」在注册时取最小空闲号分配，会随内核/驱动更新、
--   或 dGPU 是否注册（如 VFIO 直通时 NVIDIA 不注册）而变化 → 写死名字迟早失效。
--   desc: 匹配的是显示器自身的 EDID 描述，插在哪个口、挂在哪块 GPU 上都不受影响。
-- 取描述前缀的方法：`hyprctl monitors` 里 description 字段，去掉末尾的 (端口名)。
local LAPTOP = "desc:Sharp Corporation LQ156T1JW05" -- 内屏 Sharp LQ156T1JW05（EDID 厂商 SHP）
local EXTERNAL = "desc:YCT Sculptor" -- 外接屏，EDID 描述：YCT Sculptor 0000

hl.monitor({
	output = LAPTOP,
	mode = "preferred",
	position = "0x0",
	scale = 1,
})

hl.monitor({
	output = EXTERNAL,
	mode = "2560x1600@120",
	position = "-1600x0",
	scale = 1,
	transform = 1,
	-- 向右旋转90度
})

-- 工作区分配（同样用 desc:，与连接器名解耦）
-- 1-5 号 → 内屏，1 号为默认；6-10 号 → 外接屏，6 号为默认
for w = 1, 5 do
	hl.workspace_rule({ workspace = tostring(w), monitor = LAPTOP, default = (w == 1) })
end

for w = 6, 10 do
	hl.workspace_rule({ workspace = tostring(w), monitor = EXTERNAL, default = (w == 6) })
end

-- Configs
require("hyprland.env")
require("hyprland.general")
require("hyprland.input")
require("hyprland.misc")
require("hyprland.animations")
require("hyprland.decoration")
require("hyprland.group")
require("hyprland.execs")
require("hyprland.rules")
require("hyprland.gestures")
require("hyprland.keybinds")

-- User configs
maybe_create(home .. "/.config/caelestia/hypr-user.lua")
require("hypr-user")
