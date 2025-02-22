return {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5",
    dependencies = {
        "nvim-lua/plenary.nvim",
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }
    },
    config = function()
        local telescope = require('telescope')
        telescope.setup({
            extensions = {
                fzf = {
                    fuzzy = true,                   -- false will only do exact matching
                    override_generic_sorter = true, -- override the generic sorter
                    override_file_sorter = true,    -- override the file sorter
                    case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
                },
            },
            defaults = {
                file_ignore_patterns = { "^.git/", "^.venv/" },
            },
            pickers = {
                live_grep = {
                    additional_args = function(opts)
                        return { "--hidden" }
                    end
                },
                grep_string = {
                    additional_args = function(opts)
                        return { "--hidden" }
                    end
                }
            },
        })
        telescope.load_extension('fzf')

        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>pf', function()
            builtin.find_files({ hidden = true })
        end, {})
        vim.keymap.set('n', '<C-p>', builtin.git_files, {})
        vim.keymap.set('n', '<leader>pws', function()
            local word = vim.fn.expand("<cword>")
            builtin.grep_string({ search = word })
        end)
        vim.keymap.set('n', '<leader>pWs', function()
            local word = vim.fn.expand("<cWORD>")
            builtin.grep_string({ search = word })
        end)
        vim.keymap.set('n', '<leader>ps', builtin.live_grep, {})
        vim.keymap.set('n', '<leader>vh', builtin.help_tags, {})
        vim.keymap.set('n', '<leader>vk', builtin.keymaps, {})
        vim.keymap.set('v', '<leader>pv', function()
            local saved_reg = vim.fn.getreg('v')
            vim.cmd('normal! "vy"')
            local selected_text = vim.fn.getreg('v')
            vim.fn.setreg('v', saved_reg)
            builtin.grep_string({ search = selected_text })
        end)

        require('wovw.lazy.telescope.multigrep').setup()
    end
}
