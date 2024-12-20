---@diagnostic disable: unused-local, unused-function

local state = {
    floating = {
        buf = -1,
        win = -1,
    }
}

local function open_floating_window(opts)
    opts = opts or {}
    local width = opts.width or 0.8
    local height = opts.height or 0.8

    -- Get the editor's dimensions
    local columns = vim.o.columns
    local lines = vim.o.lines

    -- Calculate window size
    local win_width = math.floor(columns * width)
    local win_height = math.floor(lines * height)

    -- Calculate starting position
    local row = math.floor((lines - win_height) / 2)
    local col = math.floor((columns - win_width) / 2)

    -- Create a new buffer for the terminal
    local buf = nil
    if vim.api.nvim_buf_is_valid(opts.buf) then
        buf = opts.buf
    else
        buf = vim.api.nvim_create_buf(false, true)
    end

    -- Set up the window options
    local win_opts = {
        style = "minimal",
        relative = "editor",
        width = win_width,
        height = win_height,
        row = row,
        col = col,
        border = "rounded",
    }

    -- Open the floating window
    local win = vim.api.nvim_open_win(buf, true, win_opts)

    -- Enter insert mode
    vim.cmd('startinsert')

    return { buf = buf, win = win }
end

local function toggle_terminal()
    local terminal_win = state.floating.win
    if vim.api.nvim_win_is_valid(terminal_win) then
        vim.api.nvim_win_hide(terminal_win)
    else
        state.floating = open_floating_window({
            buf = state.floating.buf,
        })
        if vim.bo[state.floating.buf].buftype ~= "terminal" then
            vim.cmd.terminal()
        end
    end
end
vim.api.nvim_create_user_command('Floaterm', toggle_terminal, {})

vim.keymap.set("t", "<Tab><Tab>", "<C-\\><C-n>", { noremap = true, silent = true })
