return {
  -- 修改主题配置
  {
    "folke/tokyonight.nvim",
    lazy = false,
    opts = {
      transparent = true,     -- ✅ 开启透明模式
      styles = {
        sidebars = "transparent", -- 侧边栏透明
        floats = "transparent",   -- 浮动窗口透明
      },
    },
  },
}
