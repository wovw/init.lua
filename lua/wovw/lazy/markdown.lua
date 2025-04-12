return {
    {
        -- https://www.lazyvim.org/extras/lang/markdown#render-markdownnvim
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons', "folke/snacks.nvim", },
        opts = {
            code = {
                sign = false,
                width = "block",
                right_pad = 1,
            },
            heading = {
                sign = false,
                icons = {},
            },
            checkbox = {
                enabled = false,
            },
        },
        ft = { "markdown", "norg", "rmd", "org", "codecompanion" },
        config = function(_, opts)
            require("render-markdown").setup(opts)
        end,
    },
    {
        -- https://www.lazyvim.org/extras/lang/markdown#markdown-previewnvim
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        -- https://github.com/iamcco/markdown-preview.nvim/issues/690
        build = function()
            require("lazy").load({ plugins = { "markdown-preview.nvim" } })
            vim.fn["mkdp#util#install"]()
        end,
        keys = {
            {
                "<leader>mp",
                ft = "markdown",
                "<cmd>MarkdownPreviewToggle<cr>",
                desc = "Markdown Preview",
            },
        },
        config = function()
            vim.cmd([[do FileType]])
        end,
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
            buffers = { write_to_disk = true, set_filetype = true },
            verbose = {                -- set to false to disable all verbose messages
                no_code_found = false, -- don't warn if otter.activate is called, but no injected code was found
            },
        }
    },
}
