local exclude = {
  "node_modules",
  ".git",
  "target",
  ".direnv",
  ".turbo",
  "_generated",
  "*lock.yaml",
}

return {
  "folke/snacks.nvim",
  opts = {
    dashboard = { enabled = false },
    lazygit = { enabled = true },
    explorer = {
      replace_netrw = true,
    },
    picker = {
      hidden = true,
      dirs = {
        vim.uv.cwd(),
      },
      sources = {
        keymaps = {
          layout = { preset = "default", preview = false },
        },
        explorer = {
          layout = { preset = "default", preview = true },
          jump = {
            close = true,
          },
          win = {
            list = {
              keys = {
                ["<c-c>"] = false, -- disable changing dir on this key
              },
            },
          },
          hidden = true,
          ignored = true,
        },
        files = {
          hidden = true,
          ignored = true,
          exclude = exclude,
        },
        grep = {
          hidden = true,
          ignored = true,
          exclude = exclude,
        },
      },
    },
  },
  keys = {
    { "<leader>e", false },
    {
      "<leader><space>",
      function()
        ---@diagnostic disable-next-line: missing-fields
        Snacks.explorer({ cwd = vim.uv.cwd() })
      end,
      desc = "Explorer Snacks (root dir)",
      remap = true,
    },
  },
}
