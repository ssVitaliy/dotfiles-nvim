--- Use 'jk' to exit from INSERT mode
vim.keymap.set('i', 'jk', '<ESC>')
vim.keymap.set('n', '<leader><Space>', '<C-w>w', { desc = 'Cycle windows' })
vim.keymap.set('n', '<leader>pp', '"*p', { desc = 'Paste from common clipboard' })

