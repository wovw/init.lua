local data_path = vim.fn.stdpath("config") .. "/lua/plugins/data"
local markdownlint_cli2_path = data_path .. "/.markdownlint.jsonc"

return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        ["markdownlint-cli2"] = {
          args = { "--config", markdownlint_cli2_path, "--fix", "$FILENAME" },
        },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters = {
        ["markdownlint-cli2"] = {
          args = { "--config", markdownlint_cli2_path, "--" },
        },
      },
    },
  },
  {
    "HakonHarnes/img-clip.nvim",
    event = "VeryLazy",
    opts = {
      default = {
        embed_image_as_base64 = false,
        prompt_for_file_name = false,
        drag_and_drop = {
          insert_mode = true,
        },
        use_absolute_path = false,
        relative_to_current_file = true,
        dir_path = "assets",
        file_name = "%Y-%m-%d-%H-%M-%S",
      },
    },
    keys = {
      -- Suggested keymap
      { "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste Image from Clipboard" },
    },
  },
}
