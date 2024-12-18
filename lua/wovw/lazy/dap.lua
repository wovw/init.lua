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
        end,
    },
    {
        "mfussenegger/nvim-dap",
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
