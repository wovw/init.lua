return {
    'stevearc/oil.nvim',
    dependencies = { "echasnovski/mini.icons", opts = {} },
    config = function()
        require("oil").setup({
            keymaps = {
                ["<C-h>"] = false,
                ["<C-l>"] = false,
                ["<M-h>"] = { "actions.select", opts = { horizontal = true }, desc = "Open the entry in a horizontal split" },
                ["<M-l>"] = "actions.refresh",
                ["<C-p>"] = false
            },
            view_options = {
                show_hidden = true,
            }
        })

        vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
    end,
}
