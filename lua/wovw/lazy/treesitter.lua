return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                -- A list of parser names, or "all"
                ensure_installed = {
                    "vimdoc", "javascript", "typescript", "css", "c", "cmake", "cpp",
                    "diff", "lua", "rust", "ron", "go", "gomod", "gosum", "gowork", "graphql", "json",
                    "jsdoc", "bash", "prisma", "proto", "nix", "zig", "markdown", "markdown_inline",
                    "latex", "ninja", "rst",
                },

                -- Install parsers synchronously (only applied to `ensure_installed`)
                sync_install = false,

                -- Automatically install missing parsers when entering buffer
                -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
                auto_install = true,

                indent = {
                    enable = true
                },

                highlight = {
                    -- `false` will disable the whole extension
                    enable = true,
                    disable = function(lang, buf)
                        if lang == "html" then
                            print("disabled")
                            return true
                        end
                    end,

                    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
                    -- Set this to `true` if you depend on "syntax" being enabled (like for indentation).
                    -- Using this option may slow down your editor, and you may see some duplicate highlights.
                    -- Instead of true it can also be a list of languages
                    additional_vim_regex_highlighting = { "markdown" },
                },

                -- jupyter
                textobjects = {
                    move = {
                        enable = true,
                        set_jumps = false, -- you can change this if you want.
                        goto_next_start = {
                            --- ... other keymaps
                            ["]b"] = { query = "@code_cell.inner", desc = "next code block" },
                        },
                        goto_previous_start = {
                            --- ... other keymaps
                            ["[b"] = { query = "@code_cell.inner", desc = "previous code block" },
                        },
                    },
                    select = {
                        enable = true,
                        lookahead = true, -- you can change this if you want
                        keymaps = {
                            --- ... other keymaps
                            ["ib"] = { query = "@code_cell.inner", desc = "in block" },
                            ["ab"] = { query = "@code_cell.outer", desc = "around block" },
                        },
                    },
                    swap = { -- Swap only works with code blocks that are under the same
                        -- markdown header
                        enable = true,
                        swap_next = {
                            --- ... other keymap
                            ["<leader>sbl"] = "@code_cell.outer",
                        },
                        swap_previous = {
                            --- ... other keymap
                            ["<leader>sbh"] = "@code_cell.outer",
                        },
                    },
                }
            })
        end
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        config = function()
            require("treesitter-context").setup({
                enable = true,
                max_lines = 2,
            })
            vim.cmd [[highlight TreesitterContext guibg=NONE ctermbg=NONE]]
        end
    },
    {
        "hiphish/rainbow-delimiters.nvim",
        config = function()
            require('rainbow-delimiters.setup').setup({
                query = {
                    javascript = 'rainbow-parens',
                    tsx = 'rainbow-parens',
                }
            })
        end
    },
    {
        "p00f/clangd_extensions.nvim",
        lazy = true,
        config = function() end,
        opts = {
            inlay_hints = {
                inline = false,
            },
            ast = {
                --These require codicons (https://github.com/microsoft/vscode-codicons)
                role_icons = {
                    type = "",
                    declaration = "",
                    expression = "",
                    specifier = "",
                    statement = "",
                    ["template argument"] = "",
                },
                kind_icons = {
                    Compound = "",
                    Recovery = "",
                    TranslationUnit = "",
                    PackExpansion = "",
                    TemplateTypeParm = "",
                    TemplateTemplateParm = "",
                    TemplateParamObject = "",
                },
            },
        },
    }
}
