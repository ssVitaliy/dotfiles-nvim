-- Set <leader>
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.o.autochdir = true -- Auto change dir
vim.o.number = true -- line numbers default
-- vim.o.relativenumber = true  -- relative line numbers

vim.opt.tabstop = 4 -- Number of spaces a TAB counts for
vim.opt.shiftwidth = 4 -- Number of spaces to use for autoindent
vim.opt.softtabstop = 4 -- Number of spaces a TAB counts for while editing
vim.opt.expandtab = true -- Convert tabs to spaces (recommended for Python)

vim.o.mouse = "a" -- Enable mouse mode, can be useful for resizing splits for example!

-- vim.o.showmode = false  -- Don't show the mode, since it's already in the status line

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  See `:help 'clipboard'`
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

vim.o.breakindent = true -- Enable break indent

-- vim.o.undofile = true  -- Save undo history

vim.o.ignorecase = true -- Case-insensitive searching
vim.o.smartcase = true --

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
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.o.inccommand = "split" -- Preview substitutions live, as you type!

vim.o.scrolloff = 8 -- Minimal number of screen lines to keep above and below the cursor.

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true
