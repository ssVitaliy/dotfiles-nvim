vim.keymap.set("n", "<leader>k", "V", { remap = true, desc = "Visual line selection" })

-- experimental stuff
vim.keymap.set("n", "<leader>acd", ":Cdf<CR>", { desc = "cd to current buff path" })
vim.keymap.set("n", "<leader>c", "gcc", { remap = true, desc = "Comment line" })
vim.keymap.set("v", "<leader>c", [[mpgc'p]], { remap = true, desc = "Comment selection" })
vim.keymap.set("n", "<leader>gh", '"hyiw:h <C-r>h<CR>', { desc = "Help word under cursor" })

-- hard coded keys
vim.keymap.set("i", "jk", "<ESC>") -- Use 'jk' to exit from INSERT mode
vim.keymap.set("n", "<Esc>", ":nohlsearch<CR>", { silent = true }) -- Turn off search highlight

-- Text Editor
vim.keymap.set(
	"n",
	"<leader>aeu",
	':lua vim.fn.append(vim.fn.getpos(".")[2], string.rep("-", #vim.api.nvim_get_current_line()))<CR>',
	{ desc = "Underline" }
)

-- Yank to / paste from register 't'
vim.keymap.set({ "n", "v" }, "<leader>y", '"*y', { desc = "Yank to clipboard" })
vim.keymap.set("n", "<leader>p", '"*p', { desc = "Paste from clipboard" })

-- Tabs
vim.keymap.set("n", "<leader>tt", ":tab split<CR>", { desc = "Open in new tab" })
vim.keymap.set("n", "<leader>tc", ":tabc<CR>", { desc = "Close tab" })

-- Moves in INSERT mode
vim.keymap.set("i", "<C-o>", "<C-o>A", { desc = "I goto line end" })
vim.keymap.set("i", "<C-i>", "<C-o>^", { desc = "I goto firts char" })
vim.keymap.set("i", "<C-j>", "<C-o>o", { desc = "I goto new line" })
vim.keymap.set("i", "<C-d>", "<Del>", { desc = "i del previous" })

-- Navigation
vim.keymap.set("n", "<leader>n", ":Navbuddy<CR>", { desc = "Navbuddy" })
vim.keymap.set("n", "_", "<CMD>Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "<leader>ok", ":tabe ~/.config/nvim/lua/keymaps.lua<CR>", { desc = "Configs" })

--Sessions
vim.keymap.set("n", "<leader>qs", ":mks! .mks |:qa<CR>", { desc = "QuitAll with save session" })
vim.keymap.set("n", "<leader>ql", ":source .mks<CR>", { desc = "Load session if .mks exists" })

-- middle coded
vim.keymap.set("n", "<leader>wf", ":w<CR>", { desc = "Write current file" })
vim.keymap.set("n", "<leader>ad", ":DiffviewOpen<CR>", { desc = "Diffview Open" })
vim.keymap.set("n", "<leader>d", '"_d', { desc = "Delete to nil" })

-- Eval in Lua
vim.keymap.set("n", "<leader>el", ":.lua<CR>", { desc = "Eval one line in lua" })
vim.keymap.set("v", "<leader>el", ":lua<CR>", { desc = "Eval selection in lua" })
vim.keymap.set("n", "<leader>ea", ":%lua<CR>", { desc = "Eval entire buffer" })

-- vim.keymap.set("n", "<leader>t", ":30Vex!<CR>", { desc = "Left side Explorer" })
vim.keymap.set("n", "<leader>`", ":Neogit<CR>", { desc = "open neoGit" })
vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, { desc = "Diag message float" })

-- Move lines up/down
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Better indenting in visual mode
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })
