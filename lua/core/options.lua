vim.cmd([[language en_US.UTF-8]])

-- Set encoding for file content
vim.opt.encoding = "UTF-8"
vim.opt.fileencoding = "utf-8"

vim.o.shellcmdflag = "-c" -- Set up shell

vim.g.mapleader = " " -- Set global <leader>
vim.g.maplocalleader = " " -- Set local <leader>

vim.cmd.colorscheme("habamax")

-- Basic settings
vim.opt.number = true -- Line numbers
vim.opt.relativenumber = true -- Relative line numbers
vim.opt.cursorline = true -- Highlight current line
vim.opt.wrap = false -- Don't wrap lines
vim.opt.scrolloff = 8 -- Keep 10 lines above/below cursor
vim.opt.sidescrolloff = 8 -- Keep 8 columns left/right of cursor

-- Indentation
vim.opt.tabstop = 2 -- Tab width
vim.opt.shiftwidth = 2 -- Indent width
vim.opt.softtabstop = 2 -- Soft tab stop
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.smartindent = true -- Smart auto-indenting
vim.opt.autoindent = true -- Copy indent from current line

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

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  See `:help 'clipboard'`
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

vim.o.breakindent = true -- Enable break indent

-- vim.o.undofile = true  -- Save undo history

vim.o.signcolumn = "yes" -- Keep signcolumn on by default

-- vim.o.updatetime = 250  -- Decrease update time

vim.o.timeoutlen = 300 -- Decrease mapped sequence wait time

vim.o.splitright = true -- Configure how new splits should be opened
vim.o.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
--
--  Notice listchars is set using `vim.opt` instead of `vim.o`.
--  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
--   See `:help lua-options`
--   and `:help lua-options-guide`
vim.o.list = false
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.o.inccommand = "split" -- Preview substitutions live, as you type!

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true
