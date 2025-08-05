-- hard coded keys
vim.keymap.set("i", "jk", "<ESC>") -- Use 'jk' to exit from INSERT mode
vim.keymap.set("n", "<leader>pp", '"*p', { desc = "Paste from common clipboard" })
vim.keymap.set("n", "<Esc>", ":nohlsearch<CR>") -- Turn off search highlight

-- middle coded
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Write current file" })
vim.keymap.set("n", "<leader>ad", ":DiffviewOpen<CR>", { desc = "Diffview Open" })

-- Yank to / paste from register 't'
vim.keymap.set({ "n", "v" }, "<leader>y", '"*y', { desc = "Yank to clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>p", '"*p', { desc = "Paste to clipboard" })

-- temporary
vim.keymap.set("n", "<leader>t", ":tab split<CR>", { desc = "Open in new tab" })
vim.keymap.set("n", "<leader>tt", ":tabc<CR>", { desc = "Close tab" })

vim.keymap.set("n", "<leader>el", ":.lua<CR>", { desc = "Eval one line in lua" })
vim.keymap.set("n", "<leader>ea", ":%lua<CR>", { desc = "Eval entire buffer" })

-- vim.keymap.set("n", "<leader>t", ":30Vex!<CR>", { desc = "Left side Explorer" })
vim.keymap.set("n", "<leader>`", ":Neogit<CR>", { desc = "open neoGit" })

vim.keymap.set("n", "<leader>m", vim.diagnostic.open_float, { desc = "Write current file" })
