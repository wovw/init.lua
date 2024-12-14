vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.showmode = false

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"

vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.termguicolors = true
vim.g.have_nerd_font = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"

vim.opt.updatetime = 50

vim.opt.smartindent = true
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.textwidth = 80
vim.opt.breakindent = true         -- Preserve indentation in wrapped lines
vim.opt.breakindentopt = "shift:2" -- Shift wrapped lines
vim.opt.formatoptions = {
	["t"] = true,                  -- Auto-wrap text using textwidth
	["c"] = true,                  -- Auto-wrap comments using textwidth
	["q"] = true,                  -- Allow formatting of comments with "gq"
	["j"] = true,                  -- Remove comment leader when joining lines
	["n"] = true,                  -- Recognize numbered lists
	["1"] = true,                  -- Don't break a line after a one-letter word
}

vim.opt.splitright = true
vim.opt.splitbelow = true
