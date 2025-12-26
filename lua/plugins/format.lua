local data_path = vim.fn.stdpath("config") .. "/lua/plugins/data"
local markdownlint_cli2_path = data_path .. "/.markdownlint.jsonc"

return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        oxfmt = {},
        ["markdownlint-cli2"] = {
          args = { "--config", markdownlint_cli2_path, "--fix", "$FILENAME" },
        },
      },
      formatters_by_ft = {
        javascript = { "oxfmt" },
        typescript = { "oxfmt" },
        javascriptreact = { "oxfmt" },
        typescriptreact = { "oxfmt" },
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
