-- LazyVim Markdown 阅读体验优化
return {
  -- 关闭 markdownlint 的 Lint 诊断
  -- 默认会报 MD013 行长、MD033 内联 HTML、MD024 重复标题等一堆警告
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        markdown = {},
      },
    },
  },

  -- 如果关闭 lint 后仍能看到红色报错（通常是 marksman 对失效链接/重复标题的报告），
  -- 可取消下面这段注释来彻底关闭 marksman：
  -- {
  --   "neovim/nvim-lspconfig",
  --   opts = {
  --     servers = {
  --       marksman = false,
  --     },
  --   },
  -- },
}
