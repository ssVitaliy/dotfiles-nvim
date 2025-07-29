--- Use 'jk' to exit from INSERT mode
vim.keymap.set("i", "jk", "<ESC>")
vim.keymap.set("n", "<leader><Space>", "<C-w>w", { desc = "Cycle windows" })
vim.keymap.set("n", "<leader>pp", '"*p', { desc = "Paste from common clipboard" })

vim.keymap.set("n", "<leader>t", ":leftabove vertical 30split | Exp<CR>", { desc = "Left vert Explorer" })

vim.keymap.set("n", "<Esc>", ":nohlsearch<CR>") -- Turn off search highlight

vim.keymap.set("n", "<leader>el", ":.lua<CR>", { desc = "Eval one line in lua" })
vim.keymap.set("n", "<leader>eb", ":%lua<CR>", { desc = "Eval entire buffer" })
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Write current file" })
