-- nvim-cmp setup

local cmp     = require("cmp")
local lspkind = require("lspkind")

require("luasnip.loaders.from_vscode").lazy_load()
require("luasnip.loaders.from_snipmate").lazy_load()

local cmp_select = { behavior = cmp.SelectBehavior.Select }
cmp.setup({
    completion = {
        completeopt = "menu,menuone,preview,noselect",
    },
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
    mapping = {
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
        ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
        ["<C-y>"] = cmp.mapping.confirm({ select = true }),
        ["<C-Space>"] = cmp.mapping.complete(),
    },
    sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = 'render-markdown' },
        { name = "otter" },
        {
            name = "buffer",
            option = {
                get_bufnrs = function() return { vim.api.nvim_get_current_buf() } end,
            }
        },
        {
            name = "path",
            option = {
                trailing_slash = true,
            }
        }
    }),
    -- configure lspkind for vs-code like pictograms in completion menu
    formatting = {
        fields = { "abbr", "kind", "menu" },
        format = lspkind.cmp_format({
            mode = "symbol",
            maxwidth = 50,
            ellipsis_char = "...",
            before = function(entry, item)
                local menu_icon = {
                    nvim_lsp   = '',
                    path       = '',
                    cmp_nvim_r = 'R'
                }
                item.menu = menu_icon[entry.source.name]
                return item
            end,
        })
    },
})
