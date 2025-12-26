return {
  -- 告诉 LazyVim 修改 tokyonight 主题的设置
  {
    "folke/tokyonight.nvim",
    opts = {
      -- 开启背景透明
      transparent = true,
      styles = {
        -- 让侧边栏（文件树）也透明
        sidebars = "transparent",
        -- 让悬浮窗口也透明
        floats = "transparent",
      },
    },
  },
}
