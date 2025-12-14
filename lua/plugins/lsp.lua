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
      vtsls = {
        handlers = {
          -- Custom handler to filter out specific diagnostic codes
          ["textDocument/publishDiagnostics"] = function(err, result, ctx)
            if result and result.diagnostics then
              local ignored_codes = { [6196] = true } -- Unused variables
              local filtered = {}
              for _, diagnostic in ipairs(result.diagnostics) do
                if not (ignored_codes[diagnostic.code] and diagnostic.severity == 4) then
                  table.insert(filtered, diagnostic)
                  -- else
                  --   print("Ignoring diagnostic: " .. vim.inspect(diagnostic))
                end
              end
              result.diagnostics = filtered
            end
            vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx)
          end,
        },
      },
    },
  },
}
