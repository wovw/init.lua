return {
    {
        "benlubas/molten-nvim",
        dependencies = {
            {
                "3rd/image.nvim",
                build = false,
                config = function()
                    require("image").setup(                           -- image nvim options table. Pass to `require('image').setup`
                        {
                            backend = "kitty",                        -- Kitty will provide the best experience, but you need a compatible terminal
                            integrations = {},                        -- do whatever you want with image.nvim's integrations
                            max_width = 100,                          -- tweak to preference
                            max_height = 12,                          -- ^
                            max_height_window_percentage = math.huge, -- this is necessary for a good experience
                            max_width_window_percentage = math.huge,
                            window_overlap_clear_enabled = true,
                            window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
                        })
                end
            },
            {
                "GCBallesteros/jupytext.nvim",
                config = function()
                    require("jupytext").setup({
                        style = "markdown",
                        output_extension = "md",
                        force_ft = "markdown",
                    })
                end
            }
        },
        version = "^1.0.0", -- use version <2.0.0 to avoid breaking changes
        build = ":UpdateRemotePlugins",
        config = function()
            vim.g.molten_auto_open_output = false
            vim.g.molten_image_provider = "image.nvim"
            vim.g.molten_wrap_output = true
            vim.g.molten_virt_text_output = true
            vim.g.molten_virt_lines_off_by_1 = true
            vim.g.molten_enter_output_behavior = "open_and_enter"

            vim.keymap.set("n", "<leader>me", ":MoltenEvaluateOperator<CR>",
                { desc = "evaluate operator", silent = true })
            vim.keymap.set("n", "<leader>mos", ":noautocmd MoltenEnterOutput<CR>",
                { desc = "open output window", silent = true })
            vim.keymap.set("n", "<leader>mrr", ":MoltenReevaluateCell<CR>", { desc = "re-eval cell", silent = true })
            vim.keymap.set("v", "<leader>mr", ":<C-u>MoltenEvaluateVisual<CR>gv",
                { desc = "execute visual selection", silent = true })
            vim.keymap.set("n", "<leader>moh", ":MoltenHideOutput<CR>", { desc = "close output window", silent = true })
            vim.keymap.set("n", "<leader>md", ":MoltenDelete<CR>", { desc = "delete Molten cell", silent = true })

            local imb = function(e) -- init molten buffer
                vim.schedule(function()
                    local kernels = vim.fn.MoltenAvailableKernels()
                    local try_kernel_name = function()
                        local metadata = vim.json.decode(io.open(e.file, "r"):read("a"))["metadata"]
                        return metadata.kernelspec.name
                    end
                    local ok, kernel_name = pcall(try_kernel_name)
                    if not ok or not vim.tbl_contains(kernels, kernel_name) then
                        kernel_name = nil
                        local venv = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")
                        if venv ~= nil then
                            kernel_name = string.match(venv, "([^/]+)/%.venv/?$")
                        end
                    end
                    if kernel_name ~= nil and vim.tbl_contains(kernels, kernel_name) then
                        vim.cmd(("MoltenInit %s"):format(kernel_name))
                    end
                    vim.cmd("MoltenImportOutput")
                end)
            end

            -- automatically import output chunks from a jupyter notebook
            vim.api.nvim_create_autocmd("BufAdd", {
                pattern = { "*.ipynb" },
                callback = imb,
            })

            -- we have to do this as well so that we catch files opened like nvim ./hi.ipynb
            vim.api.nvim_create_autocmd("BufEnter", {
                pattern = { "*.ipynb" },
                callback = function(e)
                    if vim.api.nvim_get_vvar("vim_did_enter") ~= 1 then
                        imb(e)
                    end
                end,
            })

            -- automatically export output chunks to a jupyter notebook on write
            vim.api.nvim_create_autocmd("BufWritePost", {
                pattern = { "*.ipynb" },
                callback = function()
                    if require("molten.status").initialized() == "Molten" then
                        vim.cmd("MoltenExportOutput!")
                    end
                end,
            })

            -- change the configuration when editing a python file
            vim.api.nvim_create_autocmd("BufEnter", {
                pattern = "*.py",
                callback = function(e)
                    if string.match(e.file, ".otter.") then
                        return
                    end
                    if require("molten.status").initialized() == "Molten" then -- this is kinda a hack...
                        vim.fn.MoltenUpdateOption("virt_lines_off_by_1", false)
                        vim.fn.MoltenUpdateOption("virt_text_output", false)
                    else
                        vim.g.molten_virt_lines_off_by_1 = false
                        vim.g.molten_virt_text_output = false
                    end
                end,
            })

            -- Undo those config changes when we go back to a markdown or quarto file
            vim.api.nvim_create_autocmd("BufEnter", {
                pattern = { "*.qmd", "*.md" },
                callback = function(e)
                    if string.match(e.file, ".otter.") then
                        return
                    end
                    if require("molten.status").initialized() == "Molten" then
                        vim.fn.MoltenUpdateOption("virt_lines_off_by_1", true)
                        vim.fn.MoltenUpdateOption("virt_text_output", true)
                    else
                        vim.g.molten_virt_lines_off_by_1 = true
                        vim.g.molten_virt_text_output = true
                    end
                end,
            })

            -- Provide a command to create a blank new Python notebook
            -- note: the metadata is needed for Jupytext to understand how to parse the notebook.
            -- if you use another language than Python, you should change it in the template.
            local default_notebook = [[
          {
            "cells": [
             {
              "cell_type": "markdown",
              "metadata": {},
              "source": [
                ""
              ]
             }
            ],
            "metadata": {
             "kernelspec": {
              "display_name": "Python 3",
              "language": "python",
              "name": "python3"
             },
             "language_info": {
              "codemirror_mode": {
                "name": "ipython"
              },
              "file_extension": ".py",
              "mimetype": "text/x-python",
              "name": "python",
              "nbconvert_exporter": "python",
              "pygments_lexer": "ipython3"
             }
            },
            "nbformat": 4,
            "nbformat_minor": 5
          }
        ]]

            local function new_notebook(filename)
                local path = filename .. ".ipynb"
                local file = io.open(path, "w")
                if file then
                    file:write(default_notebook)
                    file:close()
                    vim.cmd("edit " .. path)
                else
                    print("Error: Could not open new notebook file for writing.")
                end
            end

            vim.api.nvim_create_user_command('NewNotebook', function(opts)
                new_notebook(opts.args)
            end, {
                nargs = 1,
                complete = 'file'
            })
        end,
    }
}
