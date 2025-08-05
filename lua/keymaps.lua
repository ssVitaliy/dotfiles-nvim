--- Use 'jk' to exit from INSERT mode
vim.keymap.set("i", "jk", "<ESC>")
vim.keymap.set("n", "<leader><Space>", "<C-w>w", { desc = "Cycle windows" })
vim.keymap.set("n", "<leader>pp", '"*p', { desc = "Paste from common clipboard" })

vim.keymap.set("n", "<leader>t", ":30Vex!<CR>", { desc = "Left vert Explorer" })

vim.keymap.set("n", "<Esc>", ":nohlsearch<CR>") -- Turn off search highlight

vim.keymap.set("n", "<leader>rl", ":.lua<CR>", { desc = "Eval one line in lua" })
vim.keymap.set("n", "<leader>rb", ":%lua<CR>", { desc = "Eval entire buffer" })
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Write current file" })
