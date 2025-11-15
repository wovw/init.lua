local exclude = {
  "node_modules",
  ".git",
  "target",
  ".direnv",
  ".turbo",
  "_generated",
  "*lock.yaml",
}

return {
  "folke/snacks.nvim",
  opts = {
    dashboard = { enabled = false },
    lazygit = { enabled = true },
    explorer = {
      replace_netrw = true,
    },
    picker = {
      hidden = true,
      dirs = {
        vim.uv.cwd(),
      },
      sources = {
        keymaps = {
          layout = { preset = "default", preview = false },
        },
        explorer = {
          layout = { preset = "default", preview = true },
          jump = {
            close = true,
          },
          win = {
            list = {
              keys = {
                ["<c-c>"] = false, -- disable changing dir on this key
              },
            },
          },
          -- Initially show gitignored files, but hide them when searching
          ignored = true,
          on_show = function(picker)
            -- We need to track the *previous* state of the input
            -- to avoid re-running the finder on *every* keystroke,
            -- only when it crosses the empty/non-empty boundary.
            local last_pattern_was_empty = true
            vim.api.nvim_create_autocmd("TextChangedI", {
              -- Create a unique, clearable augroup
              group = vim.api.nvim_create_augroup("SnacksExplorerIgnoredToggle", { clear = true }),
              buffer = picker.input.win.buf,
              callback = function()
                local current_pattern_is_empty = (picker.input.filter.pattern == "")

                -- Only act if the empty/non-empty state changes
                if current_pattern_is_empty ~= last_pattern_was_empty then
                  -- If we are STARTING to search (empty -> not empty)
                  if not current_pattern_is_empty then
                    picker.opts.ignored = false
                    picker:find() -- Re-run the finder

                  -- If we just CLEARED the search (not empty -> empty)
                  else
                    picker.opts.ignored = true
                    picker:find()
                  end

                  -- Update the state for the next event
                  last_pattern_was_empty = current_pattern_is_empty
                end
              end,
            })
          end,

          -- 3. Clean up the autocommand when the picker closes
          on_close = function(_)
            vim.api.nvim_create_augroup("SnacksExplorerIgnoredToggle", { clear = true })
          end,
        },
        files = {
          hidden = true,
          ignored = true,
          exclude = exclude,
        },
        grep = {
          hidden = true,
          ignored = true,
          exclude = exclude,
        },
      },
    },
  },
  keys = {
    { "<leader>e", false },
    {
      "<leader><space>",
      function()
        ---@diagnostic disable-next-line: missing-fields
        Snacks.explorer({ cwd = vim.uv.cwd() })
      end,
      desc = "Explorer Snacks (root dir)",
      remap = true,
    },
  },
}
