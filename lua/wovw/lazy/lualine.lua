-- https://github.com/nvim-lualine/lualine.nvim/pull/1212
local transparent = {
    normal = {
        a = { bg = 'None', gui = 'bold' },
        b = { bg = 'None', gui = 'bold' },
        c = { bg = 'None', gui = 'bold' },
        x = { bg = 'None', gui = 'bold' },
        y = { bg = 'None', gui = 'bold' },
        z = { bg = 'None', gui = 'bold' },
    },
    insert = {
        a = { bg = 'None', gui = 'bold' },
        b = { bg = 'None', gui = 'bold' },
        c = { bg = 'None', gui = 'bold' },
        x = { bg = 'None', gui = 'bold' },
        y = { bg = 'None', gui = 'bold' },
        z = { bg = 'None', gui = 'bold' },
    },
    visual = {
        a = { bg = 'None', gui = 'bold' },
        b = { bg = 'None', gui = 'bold' },
        c = { bg = 'None', gui = 'bold' },
        x = { bg = 'None', gui = 'bold' },
        y = { bg = 'None', gui = 'bold' },
        z = { bg = 'None', gui = 'bold' },
    },
    replace = {
        a = { bg = 'None', gui = 'bold' },
        b = { bg = 'None', gui = 'bold' },
        c = { bg = 'None', gui = 'bold' },
        x = { bg = 'None', gui = 'bold' },
        y = { bg = 'None', gui = 'bold' },
        z = { bg = 'None', gui = 'bold' },
    },
    command = {
        a = { bg = 'None', gui = 'bold' },
        b = { bg = 'None', gui = 'bold' },
        c = { bg = 'None', gui = 'bold' },
        x = { bg = 'None', gui = 'bold' },
        y = { bg = 'None', gui = 'bold' },
        z = { bg = 'None', gui = 'bold' },
    },
    inactive = {
        a = { bg = 'None', gui = 'bold' },
        b = { bg = 'None', gui = 'bold' },
        c = { bg = 'None', gui = 'bold' },
        x = { bg = 'None', gui = 'bold' },
        y = { bg = 'None', gui = 'bold' },
        z = { bg = 'None', gui = 'bold' },
    },
}

return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'echasnovski/mini.icons' },
    config = function()
        require('lualine').setup({
            options = {
                theme = transparent,
            },
            sections = {
                lualine_c = {
                    {
                        'filename',
                        path = 1
                    }
                }
            }
        })

        local base_statusline_highlights = {'StatusLine', 'StatusLineNC', 'Tabline', 'TabLineFill', 'TabLineSel', 'Winbar', 'WinbarNC'}
        for _, hl_group in pairs(base_statusline_highlights) do
          vim.api.nvim_set_hl(0, hl_group, { bg = 'none' })
        end
    end
}
