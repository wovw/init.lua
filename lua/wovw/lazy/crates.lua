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
                cmp = {
                    enabled = true,
                }
            }
        })
        crates.show()
    end,
}
