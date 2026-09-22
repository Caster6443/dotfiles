-- YAML 缩进：用 Neovim 自带规则（GetYAMLIndent），并关掉 LazyVim 全局开的 smartindent
-- （smartindent 是 C 风格规则，在 YAML 上会给出多余缩进；自带的 yaml 脚本本来也会 nosmartindent）
vim.opt_local.smartindent = false
vim.opt_local.cindent = false

vim.b.did_indent = nil              -- 清掉加载标记，确保下面这次加载一定生效
vim.cmd("runtime! indent/yaml.vim") -- 设 indentexpr=GetYAMLIndent / indentkeys / nosmartindent

vim.opt_local.shiftwidth = 2
vim.opt_local.softtabstop = 2
vim.opt_local.expandtab = true

-- 如果哪天你连这点自动缩进都不想要（回车只照抄上一行），把上面两行换成：
--   vim.opt_local.indentexpr = ""
--   vim.opt_local.indentkeys = ""
