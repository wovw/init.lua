return {
    {
        "leoluz/nvim-dap-go",
        dependencies = {
            "mfussenegger/nvim-dap",
        },
        ft = "go",
        config = function()
            local dap_go = require("dap-go")
            dap_go.setup()
            vim.keymap.set("n", "<leader>bgt", function() dap_go.debug_test() end, { desc = "Debug go test" })
            vim.keymap.set("n", "<leader>bgl", function() dap_go.debug_last() end, { desc = "Debug last go test" })
        end
    },
    {
        "mfussenegger/nvim-dap-python",
        dependencies = {
            "mfussenegger/nvim-dap",
        },
        ft = "python",
        config = function()
            local dap_python = require("dap-python")
            dap_python.setup("uv")
            vim.keymap.set("n", "<leader>bpr", function() dap_python.test_method() end, { desc = "Debug python test" })
        end
    },
    {
        "rcarriga/nvim-dap-ui",
        event = "VeryLazy",
        dependencies = {
            "mfussenegger/nvim-dap",
            "nvim-neotest/nvim-nio"
        },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")
            dapui.setup()
            dap.listeners.before.attach.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.launch.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated.dapui_config = function()
                dapui.close()
            end
            dap.listeners.before.event_exited.dapui_config = function()
                dapui.close()
            end

            vim.keymap.set("n", "<leader>bt", function() dapui.toggle() end, { desc = "Toggle debug UI" })
        end,
    },
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            {
                "theHamsta/nvim-dap-virtual-text",
                opts = {
                    enabled = true,                     -- enable this plugin (the default)
                    enabled_commands = true,            -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
                    highlight_changed_variables = true, -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
                    highlight_new_as_changed = false,   -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
                    show_stop_reason = true,            -- show stop reason when stopped for exceptions
                    commented = false,                  -- prefix virtual text with comment string
                    only_first_definition = true,       -- only show virtual text at first definition (if there are multiple)
                    all_references = false,             -- show virtual text on all all references of the variable (not only definitions)
                    clear_on_continue = false,          -- clear virtual text on "continue" (might cause flickering when stepping)
                    --- A callback that determines how a variable is displayed or whether it should be omitted
                    --- @param variable Variable https://microsoft.github.io/debug-adapter-protocol/specification#Types_Variable
                    --- @param buf number
                    --- @param stackframe dap.StackFrame https://microsoft.github.io/debug-adapter-protocol/specification#Types_StackFrame
                    --- @param node userdata tree-sitter node identified as variable definition of reference (see `:h tsnode`)
                    --- @param options nvim_dap_virtual_text_options Current options for nvim-dap-virtual-text
                    --- @return string|nil A text how the virtual text should be displayed or nil, if this variable shouldn't be displayed
                    display_callback = function(variable, buf, stackframe, node, options)
                        if options.virt_text_pos == "inline" then
                            return " = " .. variable.value
                        else
                            return variable.name .. " = " .. variable.value
                        end
                    end,
                    -- virt_text_pos = vim.fn.has("nvim-0.10") == 1 and "inline" or "eol",
                    virt_text_pos = "eol",

                    -- experimental features:
                    all_frames = false,      -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
                    virt_lines = false,      -- show virtual lines instead of virtual text (will flicker!)
                    virt_text_win_col = nil, -- position the virtual text at a fixed window column (starting from the first text column) ,
                    -- e.g. 80 to position at column 80, see `:h nvim_buf_set_extmark()`
                },
            },
        },
        config = function()
            local dap = require("dap")
            vim.keymap.set("n", "<leader>bs", function()
                local widgets = require("dap.ui.widgets")
                local sidebar = widgets.scopes(widgets.scopes())
                sidebar.open()
            end, { desc = "Open debug sidebar" })
            vim.keymap.set("n", "<leader>bb", function() dap.toggle_breakpoint() end)
            vim.keymap.set("n", "<leader>bc", function() dap.continue() end)
            vim.keymap.set("n", "<leader>bd", function() dap.step_back() end)
            vim.keymap.set("n", "<leader>bi", function() dap.step_into() end)
            vim.keymap.set("n", "<leader>bo", function() dap.step_out() end)
            vim.keymap.set("n", "<leader>bp", function() dap.step_over() end)
            vim.keymap.set("n", "<leader>bq", function() dap.close() end)
            vim.keymap.set("n", "<leader>br", function() dap.repl.toggle() end)

            -- CodeLLDB config
            dap.adapters.codelldb = {
                type = 'server',
                port = "${port}",
                executable = {
                    command = vim.fn.stdpath("data") .. '/mason/bin/codelldb',
                    args = { "--port", "${port}" },
                }
            }
            dap.configurations.cpp = {
                {
                    name = "Debug file",
                    type = "codelldb",
                    request = "launch",
                    program = function()
                        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                    end,
                    cwd = '${workspaceFolder}',
                    stopOnEntry = false,
                    console = 'integratedTerminal',
                },
            }
            dap.configurations.c = dap.configurations.cpp
        end,
    }
}
