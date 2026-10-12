-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Keep newline and pair exit separate from completion acceptance.
local function hide_completion()
  local ok, cmp = pcall(require, "blink.cmp")
  if ok then cmp.hide() end
end

vim.keymap.set("i", "<S-CR>", function()
  hide_completion()
  return require("mini.pairs").cr()
end, { expr = true, desc = "Newline without accepting completion" })

vim.keymap.set("i", "<Tab>", function()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local next_char = vim.api.nvim_get_current_line():sub(cursor[2] + 1, cursor[2] + 1)
  if next_char ~= "" and string.find(")]}'\"`", next_char, 1, true) then
    hide_completion()
    return "<Right>"
  end
  return "<Tab>"
end, { expr = true, desc = "Skip adjacent closing delimiter or indent" })
