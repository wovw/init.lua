return {
    "hrsh7th/nvim-cmp",
    event = {
        "InsertEnter",
        "CmdlineEnter",
    },
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/cmp-nvim-lua",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "rafamadriz/friendly-snippets",
        "onsails/lspkind.nvim",
        'MeanderingProgrammer/render-markdown.nvim',
        'saecki/crates.nvim',
        'jmbuhr/otter.nvim',
        "p00f/clangd_extensions.nvim",
        { "roobert/tailwindcss-colorizer-cmp.nvim", opts = {} },
    },
    opts = function(_, opts)
        opts.sorting = opts.sorting or {}
        opts.sorting.comparators = opts.sorting.comparators or {}

        -- clangd completions
        table.insert(opts.sorting.comparators, 1, require("clangd_extensions.cmp_scores"))

        -- lazydev (luals)
        opts.sources = opts.sources or {}
        table.insert(opts.sources, {
            name = "lazydev",
            group_index = 0, -- set group index to 0 to skip loading LuaLS completions
        })

        -- https://www.lazyvim.org/extras/lang/python#nvim-cmp-optional
        opts.auto_brackets = opts.auto_brackets or {}
        table.insert(opts.auto_brackets, "python")

        -- original LazyVim kind icon formatter (https://www.lazyvim.org/extras/lang/tailwind#nvim-cmp-optional)
        opts.formatting = opts.formatting or {}
        local format_kinds = opts.formatting.format
        opts.formatting.format = function(entry, item)
            format_kinds(entry, item) -- add icons
            return require("tailwindcss-colorizer-cmp").formatter(entry, item)
        end
    end,
}
