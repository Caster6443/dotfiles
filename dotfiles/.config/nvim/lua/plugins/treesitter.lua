return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- 将 qmljs 加入到确保安装的列表中
      vim.list_extend(opts.ensure_installed, { "qmljs" })
    end,
  },
}
