return {
  "neovim/nvim-lspconfig",
  opts = {
    inlay_hints = {
      enabled = false,
    },
    servers = {
      remark_ls = {
        settings = {
          remark = {
            requireConfig = false,
          },
        },
      },
    },
  },
}
