return {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    opts = {
        -- add any opts here
        -- for example
        provider = "copilot",
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "stevearc/dressing.nvim",
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        --- The below dependencies are optional,
        "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
        "hrsh7th/nvim-cmp",              -- autocompletion for avante commands and mentions
        "echasnovski/mini.icons",        -- for icons
        {
            "ravitemer/mcphub.nvim",
            dependencies = {
                "nvim-lua/plenary.nvim",  -- Required for Job and HTTP requests
            },
            -- uncomment the following line to load hub lazily
            --cmd = "MCPHub",  -- lazy load
            build = "bundled_build.lua",  -- Use this and set use_bundled_binary = true in opts  (see Advanced configuration)
            config = function()
                require("mcphub").setup({
                    use_bundled_binary = true,
                })
            end,
        }   ,
        {
            "zbirenbaum/copilot.lua",    -- for providers='copilot'
            cmd = "Copilot",
            event = "InsertEnter",
            config = function()
                require("copilot").setup({})
            end,
        },
        {
            -- support for image pasting
            "HakonHarnes/img-clip.nvim",
            opts = {
                -- recommended settings
                default = {
                    embed_image_as_base64 = false,
                    prompt_for_file_name = false,
                    drag_and_drop = {
                        insert_mode = true,
                    },
                    -- required for Windows users
                    use_absolute_path = true,
                },
            },
        },
        {
            -- Make sure to set this up properly if you have lazy=true
            'MeanderingProgrammer/render-markdown.nvim',
            opts = {
                file_types = { "markdown", "Avante" },
            },
            ft = { "markdown", "Avante" },
        },
        {
            'nvim-lualine/lualine.nvim',
            config = function()
                require('lualine').setup({
                    sections = {
                        lualine_x = {
                            -- Other lualine components in "x" section
                            {require('mcphub.extensions.lualine')},
                        },
                    },
                })
            end,
        }
    },
    config = function()
        require("avante").setup({
            system_prompt = function()
                local hub = require("mcphub").get_hub_instance()
                return hub:get_active_servers_prompt()
            end,
            custom_tools = function()
                return {
                    require("mcphub.extensions.avante").mcp_tool(),
                }
            end,
            disabled_tools = { -- using MCPHub's native Neovim server
                "list_files",
                "search_files",
                "read_file",
                "create_file",
                "rename_file",
                "delete_file",
                "create_dir",
                "rename_dir",
                "delete_dir",
                "bash",
            },
        })
    end,

}
