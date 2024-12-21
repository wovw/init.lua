return {
    {
        "nvim-lua/plenary.nvim",
        name = "plenary"
    },
    'tpope/vim-sleuth',
    {
        "supermaven-inc/supermaven-nvim",
        config = function()
            require("supermaven-nvim").setup({
                keymaps = {
                    accept_suggestion = "<C-e>",
                    clear_suggestion = "<C-]>",
                    accept_word = "<C-h>",
                },
            })
        end,
    },
    {
        "m4xshen/hardtime.nvim",
        dependencies = { "MunifTanjim/nui.nvim" },
        opts = {
            disabled_filetypes = { "qf", "netrw", "NvimTree", "lazy", "mason", "oil" },
        }
    },
    { 'wakatime/vim-wakatime', lazy = false },
    "eandrju/cellular-automaton.nvim",
}
