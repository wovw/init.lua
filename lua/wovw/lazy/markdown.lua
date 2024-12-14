return {
    {
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons', 'hrsh7th/nvim-cmp' },
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
    }
}
