return {
    'saecki/crates.nvim',
    dependencies = {
        'nvim-lua/plenary.nvim',
    },
    tag = 'stable',
    event = { "BufRead Cargo.toml" },
    config = function()
        local crates = require("crates")
        crates.setup({
            completion = {
                crates = {
                    enabled = true,
                },
            },
            lsp = {
                enabled = true,
                actions = true,
                completion = true,
                hover = true,
            },
        })
        crates.show()
    end,
}
