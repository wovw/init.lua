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
                    accept_suggestion = "<C-o>",
                    clear_suggestion = "<C-]>",
                    accept_word = "<C-h>",
                },
            })
        end,
    },
    { 'wakatime/vim-wakatime', lazy = false },
    "eandrju/cellular-automaton.nvim",
}
