return {
  -- modified from :LazyExtras
  "saghen/blink.cmp",
  opts = {
    keymap = {
      ["<C-n>"] = { "select_next", "fallback" },
      ["<C-p>"] = { "select_prev", "fallback" },
      ["<Tab>"] = nil,
      ["<S-Tab>"] = nil,
    },
  },
}
