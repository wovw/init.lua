return {
    'stevearc/oil.nvim',
    dependencies = { "echasnovski/mini.icons", opts = {} },
    config = function()
        require("oil").setup({
            keymaps = {
                ["<C-h>"] = false,
                ["<C-l>"] = false,
                ["<M-h>"] = { "actions.select", opts = { horizontal = true }, desc = "Open the entry in a horizontal split" },
                ["<M-r>"] = "actions.refresh",
                ["<C-p>"] = false
            },
            view_options = {
                show_hidden = true,
            }
        })

        vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

        vim.api.nvim_create_autocmd("User", {
            pattern = "OilActionsPost",
            callback = function(event)
                if event.data.actions.type == "move" then
                    Snacks.rename.on_rename_file(event.data.actions.src_url, event.data.actions.dest_url)
                end
            end,
        })
    end,
}
