vim.g.snacks_animate = false

return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
        animate = { enabled = false },
        bigfile = { enabled = true },
        image = { enabled = true },
        indent = { enabled = true },
        quickfile = { enabled = true },
        rename = { enabled = true },
        scratch = { enabled = true },
        terminal = { enabled = true },
    },
    keys = {
        { "<leader>.", function() Snacks.scratch() end,        desc = "Toggle Scratch Buffer" },
        { "<leader>S", function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },

        { "<C-/>",     function() Snacks.terminal() end,       desc = "Toggle Terminal" },
    },
}
