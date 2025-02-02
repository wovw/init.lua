return {
    {
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' },
        config = function()
            require("render-markdown").setup({})
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
        dependencies = {
            {
                'neovim/nvim-lspconfig',
                'nvim-treesitter/nvim-treesitter',
            },
        },
        config = function()
            require('otter').setup({
                verbose = {
                    no_code_found = false,
                },
                buffer = {
                    set_filetype = true,
                }
            })
        end,
    },
    {
        "quarto-dev/quarto-nvim",
        ft = { "quarto", "markdown" },
        dev = false,
        dependencies = {
            "jmbuhr/otter.nvim",
            "nvim-treesitter/nvim-treesitter",
            "benlubas/molten-nvim",
        },
        config = function()
            require("quarto").setup({
                lspFeatures = {
                    languages = { "python" },
                    chunks = "all",
                    diagnostics = {
                        enabled = true,
                    },
                    completion = {
                        enabled = true,
                    },
                },
                codeRunner = {
                    enabled = true,
                    default_method = "molten",
                }
            })
        end
    },
}
