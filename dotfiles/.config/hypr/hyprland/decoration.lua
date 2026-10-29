local vars = require("variables")

hl.config({
    decoration = {
        rounding = vars.windowRounding,

        blur = {
            enabled           = vars.blurEnabled,
            xray              = vars.blurXray,
            special           = vars.blurSpecialWs,
            ignore_opacity    = true, -- Allows opacity blurring
            new_optimizations = true,
            popups            = vars.blurPopups,
            input_methods     = vars.blurInputMethods,
            size              = vars.blurSize,
            passes            = vars.blurPasses,
        },

        shadow = {
            enabled      = vars.shadowEnabled,
            range        = vars.shadowRange,
            render_power = vars.shadowRenderPower,
            color        = vars.shadowColour,
        },

        -- Hyprland 0.57 新增：移动/缩放窗口时的弹簧网格形变（俗称“窗口晃动”）。
        -- 调手感的另外三个：stiffness 刚度（越高回弹越快）、damping 阻尼（越高越快停）、
        -- mass 惯性（越高越"重"）；mesh 是网格精度 2-32，越高越平滑越吃 GPU。
        wobble = {
            enabled   = true,
            intensity = 0.35, -- 幅度：0.2 含蓄 / 0.5 明显 / 1 以上夸张
        },
    },
})
