return {
    {
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons', 'hrsh7th/nvim-cmp' },
        config = function()
            require("render-markdown").setup({})
            local cmp = require('cmp')
            cmp.setup({
                sources = cmp.config.sources({
                    { name = 'render-markdown' },
                }),
            })
        end
    },
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        ft = { "markdown" },
        -- https://github.com/iamcco/markdown-preview.nvim/issues/690
        build = function() vim.fn["mkdp#util#install"]() end,
    },
    {

        -- for lsp features in code cells / embedded code
        'jmbuhr/otter.nvim',
        dev = false,
        dependencies = {
            {
                'neovim/nvim-lspconfig',
                'nvim-treesitter/nvim-treesitter',
            },
        },
        opts = {
            verbose = {
                no_code_found = false,
            },
        },
    },
    {
        "quarto-dev/quarto-nvim",
        ft = { "quarto", "markdown" },
        opts = {
            lspFeatures = {
                languages = { "python" },
                chunks = "all",
                diagnostics = {
                    enabled = true,
                    triggers = { "BufWritePost" },
                },
                completion = {
                    enabled = true,
                },
            },
            codeRunner = {
                enabled = true,
                default_method = "molten",
            }
        },
        dependencies = {
            "jmbuhr/otter.nvim",
            "nvim-treesitter/nvim-treesitter",
            "benlubas/molten-nvim",
        },
    },
}
