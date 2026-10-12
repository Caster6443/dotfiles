return {
  {
    "saghen/blink.cmp",
    opts = {
      completion = { list = { selection = { auto_insert = false } } },
      keymap = {
        preset = "enter",
        ["<CR>"] = { "select_and_accept", "fallback" },
        -- Navigate visible candidates; otherwise use the pair-exit/indent mapping.
        ["<Tab>"] = { "select_next", "fallback" },
        ["<S-Tab>"] = { "select_prev", "fallback" },
        ["<S-CR>"] = false,
      },
    },
  },
}
