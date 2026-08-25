-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.spelllang:append("cjk")

-- 自动探测中文 Windows 常见编码（微信 Windows 端发来的 txt 多为 GBK/GB18030）
vim.opt.fileencodings = "ucs-bom,utf-8,gb18030,gbk,gb2312,latin1"
