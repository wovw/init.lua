return {
    'saecki/crates.nvim',
    tag = 'stable',
    event = { "BufRead Cargo.toml" },
    config = function()
        local crates = require("crates")
        crates.setup({
            completion = {
                cmp = {
                    enable = true,
                }
            }
        })
        crates.show()
    end,
}
