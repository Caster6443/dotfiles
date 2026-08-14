-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- =========================================================================
-- Caelestia 系统级亮暗模式同步 (终极拦截版)
-- =========================================================================

-- 核心读取函数
local function sync_caelestia_bg()
  local theme_file_path = vim.fn.expand("~/.local/state/caelestia/scheme.json")
  local f = io.open(theme_file_path, "r")
  if not f then
    return
  end
  local content = f:read("*a")
  f:close()

  local ok, parsed = pcall(vim.json.decode, content)
  if ok and type(parsed) == "table" and parsed.mode then
    local target_bg = (parsed.mode == "light") and "light" or "dark"

    -- 强行覆盖背景
    if vim.o.background ~= target_bg then
      vim.o.background = target_bg
    end
  end
end

-- 1. 冷启动杀手锏：挂载在 UIEnter 事件上
-- 这意味着等 LazyVim 和所有主题插件装x完毕、把界面画出来的那一瞬间，我们直接篡改背景
vim.api.nvim_create_autocmd("UIEnter", {
  callback = function()
    -- 延迟 10 毫秒，确保主题插件的初始化脚本死透了
    vim.defer_fn(sync_caelestia_bg, 10)
  end,
})

-- 2. 热重载监听器：你平时切换壁纸时的动态响应
local theme_dir = vim.fn.expand("~/.local/state/caelestia")
local uv = vim.uv or vim.loop
local watcher = uv.new_fs_event()

if watcher then
  watcher:start(
    theme_dir,
    {},
    vim.schedule_wrap(function(err, filename)
      if err or filename ~= "scheme.json" then
        return
      end
      -- 监听到文件变化，稍微等一下防止文件没写完，然后同步
      vim.defer_fn(sync_caelestia_bg, 50)
    end)
  )
end

-- =========================================================================
-- Markdown 阅读优化：关闭拼写红线、强制折行
-- LazyVim 默认对 markdown 开启 spell，中文文档里的英文单词会被大量标红
-- =========================================================================
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("markdown_view", { clear = true }),
  pattern = { "markdown", "markdown.mdx" },
  callback = function()
    vim.opt_local.spell = false
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end,
})
