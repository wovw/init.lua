--[[
-- https://www.lazyvim.org/extras/dap/core
-- https://github.com/LazyVim/LazyVim/blob/ec5981dfb1222c3bf246d9bcaa713d5cfa486fbd/lua/lazyvim/plugins/extras/dap/core.lua#L2
-- ]]

---@param config {type?:string, args?:string[]|fun():string[]?}
local function get_args(config)
    local args = type(config.args) == "function" and (config.args() or {}) or config.args or
        {} --[[@as string[] | string ]]
    local args_str = type(args) == "table" and table.concat(args, " ") or args --[[@as string]]

    config = vim.deepcopy(config)
    ---@cast args string[]
    config.args = function()
        local new_args = vim.fn.expand(vim.fn.input("Run with args: ", args_str)) --[[@as string]]
        if config.type and config.type == "java" then
            ---@diagnostic disable-next-line: return-type-mismatch
            return new_args
        end
        return require("dap.utils").splitstr(new_args)
    end
    return config
end

return {
    {
        "nvim-neotest/neotest",
        optional = true,
        dependencies = {
            "fredrikaverpil/neotest-golang",
            "leoluz/nvim-dap-go",
            "nvim-neotest/neotest-python",
            'mrcjkb/rustaceanvim',
            "lawrence-laz/neotest-zig",
        },
        opts = {
            adapters = {
                ["neotest-golang"] = {
                    -- Here we can set options for neotest-golang, e.g.
                    -- go_test_args = { "-v", "-race", "-count=1", "-timeout=60s" },
                    dap_go_enabled = true, -- requires leoluz/nvim-dap-go
                },
                ["neotest-python"] = {
                    -- Here you can specify the settings for the adapter, i.e.
                    -- runner = "pytest",
                    -- python = ".venv/bin/python",
                },
                ["rustaceanvim.neotest"] = {},
                ["neotest-zig"] = {},
            },
        },
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
            vim.keymap.set("n", "<leader>dpt", function() dap_python.test_method() end, { desc = "Debug python test" })
            vim.keymap.set("n", "<leader>dpc", function() dap_python.test_class() end, { desc = "Debug python class" })
        end
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
        -- stylua: ignore
        keys = {
            { "<leader>du", function() require("dapui").toggle({}) end, desc = "Dap UI" },
            { "<leader>de", function() require("dapui").eval() end,     desc = "Eval",  mode = { "n", "v" } },
        },
        opts = {},
        config = function(_, opts)
            local dap = require("dap")
            local dapui = require("dapui")
            dapui.setup(opts)
            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open({})
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close({})
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close({})
            end
        end,
    },
    {
        "mfussenegger/nvim-dap",
        recommended = true,
        desc = "Debugging support. Requires language specific adapters to be configured. (see lang extras)",
        dependencies = {
            "neovim/nvim-lspconfig", -- depends on mason to install DAP adapters defined in lsp.lua
            "jbyuki/one-small-step-for-vimkind",
            "rcarriga/nvim-dap-ui",
            {
                "theHamsta/nvim-dap-virtual-text",
                opts = {},
            },
        },
        -- stylua: ignore
        keys = {
            { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
            { "<leader>db", function() require("dap").toggle_breakpoint() end,                                    desc = "Toggle Breakpoint" },
            { "<leader>dc", function() require("dap").continue() end,                                             desc = "Run/Continue" },
            { "<leader>da", function() require("dap").continue({ before = get_args }) end,                        desc = "Run with Args" },
            { "<leader>dC", function() require("dap").run_to_cursor() end,                                        desc = "Run to Cursor" },
            { "<leader>dg", function() require("dap").goto_() end,                                                desc = "Go to Line (No Execute)" },
            { "<leader>di", function() require("dap").step_into() end,                                            desc = "Step Into" },
            { "<leader>dj", function() require("dap").down() end,                                                 desc = "Down" },
            { "<leader>dk", function() require("dap").up() end,                                                   desc = "Up" },
            { "<leader>dl", function() require("dap").run_last() end,                                             desc = "Run Last" },
            { "<leader>do", function() require("dap").step_out() end,                                             desc = "Step Out" },
            { "<leader>dO", function() require("dap").step_over() end,                                            desc = "Step Over" },
            { "<leader>dp", function() require("dap").pause() end,                                                desc = "Pause" },
            { "<leader>dr", function() require("dap").repl.toggle() end,                                          desc = "Toggle REPL" },
            { "<leader>ds", function() require("dap").session() end,                                              desc = "Session" },
            { "<leader>dt", function() require("dap").terminate() end,                                            desc = "Terminate" },
            { "<leader>dw", function() require("dap.ui.widgets").hover() end,                                     desc = "Widgets" },
        },
        config = function()
            vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

            -- setup dap config by VsCode launch.json file
            local vscode = require("dap.ext.vscode")
            local json = require("plenary.json")
            vscode.json_decode = function(str)
                return vim.json.decode(json.json_strip_comments(str))
            end

            local dap = require("dap")

            -- lua config
            dap.adapters.nlua = function(callback, conf)
                local adapter = {
                    type = "server",
                    host = conf.host or "127.0.0.1",
                    port = conf.port or 8086,
                }
                if conf.start_neovim then
                    local dap_run = dap.run
                    dap.run = function(c)
                        adapter.port = c.port
                        adapter.host = c.host
                    end
                    require("osv").run_this()
                    dap.run = dap_run
                end
                callback(adapter)
            end
            dap.configurations.lua = {
                {
                    type = "nlua",
                    request = "attach",
                    name = "Run this file",
                    start_neovim = {},
                },
                {
                    type = "nlua",
                    request = "attach",
                    name = "Attach to running Neovim instance (port = 8086)",
                    port = 8086,
                },
            }

            -- CodeLLDB config
            dap.adapters.codelldb = {
                type = 'server',
                host = "localhost",
                port = "${port}",
                executable = {
                    command = vim.fn.stdpath("data") .. '/mason/bin/codelldb',
                    args = { "--port", "${port}" },
                }
            }
            dap.configurations.cpp = {
                {
                    type = "codelldb",
                    request = "launch",
                    name = "Debug file",
                    program = function()
                        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                    end,
                    cwd = '${workspaceFolder}',
                },
                {
                    type = "codelldb",
                    request = "attach",
                    name = "Attach to process",
                    pid = require("dap.utils").pick_process,
                    cwd = "${workspaceFolder}",
                }
            }
            dap.configurations.c = dap.configurations.cpp
        end,
    }
}
