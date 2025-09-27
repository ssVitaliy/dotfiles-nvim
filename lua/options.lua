vim.cmd([[language en_US.UTF-8]])

-- Set encoding for file content
vim.opt.encoding = "UTF-8"
vim.opt.fileencoding = "utf-8"

-- Set up shell
vim.o.shellcmdflag = "-c" -- "-ic" if need to load .bashrc
vim.o.shell = "C:/msys64/usr/bin/bash.exe"
vim.o.shellquote = ""
vim.o.shellxquote = ""
vim.o.shellslash = true

vim.g.mapleader = " " -- Set global <leader>
vim.g.maplocalleader = " " -- Set local <leader>

-- vim.cmd.colorscheme("habamax") -- not required, scheme apply with lazy plugin

-- Basic settings
vim.opt.number = true -- Line numbers
vim.opt.relativenumber = false -- Relative line numbers
vim.opt.cursorline = true -- Highlight current line
vim.opt.wrap = false -- Don't wrap lines
vim.opt.scrolloff = 8 -- Keep 10 lines above/below cursor
vim.opt.sidescrolloff = 8 -- Keep 8 columns left/right of cursor

-- Indentation
vim.opt.tabstop = 2 -- Tab width
vim.opt.shiftwidth = 2 -- Indent width
vim.opt.softtabstop = 2 -- Soft tab stop
vim.opt.expandtab = false -- Use spaces instead of tabs
vim.opt.smartindent = false -- Smart auto-indenting
vim.opt.autoindent = true -- Copy indent from current line

-- Folds
vim.opt.foldmethod = "expr"
vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldenable = false
vim.o.foldlevelstart = 99
-- vim.o.foldexpr = "nvim_treesitter#foldexpr()"

-- Formatter
-- Dont insert leader comment when press 'o O Enter'
-- r: Controls automatic comment leader insertion when you press Enter in Insert mode.
-- o: Controls automatic comment leader insertion when you press o or O in Normal mode to open a new line.
vim.opt.formatoptions:remove({ "o", "r" })
vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		vim.opt_local.formatoptions:remove("o")
	end,
})

-- Search settings
vim.opt.ignorecase = true -- Case insensitive search
vim.opt.smartcase = true -- Case sensitive if uppercase in search
vim.opt.hlsearch = true -- highlight search results
vim.opt.incsearch = true -- Show matches as you type

vim.o.autochdir = false -- Auto change dir
vim.o.mouse = "a" -- Enable mouse mode

-- netrw
vim.g.netrw_banner = 0 -- turn off the banner in Netrw
vim.g.netrw_liststyle = 3 -- Tree-style listing
-- vim.g.netrw_winsize = 30 -- Window width when opening in vertical split

vim.o.breakindent = true -- Enable break indent
vim.o.undofile = true -- Save undo history
vim.o.signcolumn = "yes" -- Keep signcolumn on by default
-- vim.o.updatetime = 250  -- Decrease update time
vim.o.timeoutlen = 500 -- Decrease mapped sequence wait time

vim.o.splitright = true -- Configure how new splits should be opened
vim.o.splitbelow = true

vim.o.list = false -- Display whitespaces
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.o.inccommand = "split" -- Preview substitutions live, as you type!

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})
