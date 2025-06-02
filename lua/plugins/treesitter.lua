return {
  "nvim-treesitter/nvim-treesitter-context",
  opts = {
    enable = true,
    max_lines = 2,
  },
  config = function(_, opts)
    require("treesitter-context").setup(opts)
    vim.cmd([[highlight TreesitterContext guibg=NONE ctermbg=NONE]])
  end,
}
