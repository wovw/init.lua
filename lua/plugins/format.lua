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
        biome = {
          args = {
            "check",
            "--write",
            "--no-errors-on-unmatched",
            "--stdin-file-path",
            "$FILENAME",
          },
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
}
