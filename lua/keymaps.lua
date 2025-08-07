-- hard coded keys
vim.keymap.set("i", "jk", "<ESC>") -- Use 'jk' to exit from INSERT mode
vim.keymap.set("n", "<Esc>", ":nohlsearch<CR>") -- Turn off search highlight

-- Yank to / paste from register 't'
vim.keymap.set({ "n", "v" }, "<leader>y", '"*y', { desc = "Yank to clipboard" })
vim.keymap.set("n", "<leader>p", '"*p', { desc = "Paste to clipboard" })

-- Tabs
vim.keymap.set("n", "<leader>tt", ":tab split<CR>", { desc = "Open in new tab" })
vim.keymap.set("n", "<leader>tc", ":tabc<CR>", { desc = "Close tab" })

-- Moves in INSERT mode
vim.keymap.set("i", "<C-o>", "<C-o>A", { desc = "I goto line end" })
vim.keymap.set("i", "<C-i>", "<C-o>^", { desc = "I goto firts char" })
vim.keymap.set("i", "<C-j>", "<C-o>o", { desc = "I goto new line" })

-- middle coded
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Write current file" })
vim.keymap.set("n", "<leader>ad", ":DiffviewOpen<CR>", { desc = "Diffview Open" })

-- temporary
vim.keymap.set("n", "<leader>el", ":.lua<CR>", { desc = "Eval one line in lua" })
vim.keymap.set("n", "<leader>ea", ":%lua<CR>", { desc = "Eval entire buffer" })

-- vim.keymap.set("n", "<leader>t", ":30Vex!<CR>", { desc = "Left side Explorer" })
vim.keymap.set("n", "<leader>`", ":Neogit<CR>", { desc = "open neoGit" })

vim.keymap.set("n", "<leader>m", vim.diagnostic.open_float, { desc = "Write current file" })
