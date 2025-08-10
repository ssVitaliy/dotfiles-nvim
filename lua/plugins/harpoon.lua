return {
	"ThePrimeagen/harpoon",
	config = function()
		require("harpoon").setup({})
		vim.keymap.set("n", "<leader>hi", require("harpoon.mark").add_file, { desc = "Harpoon insert mark" })
		vim.keymap.set("n", "<leader>hh", require("harpoon.ui").toggle_quick_menu, { desc = "Harpoon menu" })
		vim.keymap.set("n", "<leader>hk", require("harpoon.ui").nav_next, { desc = "goto next mark" })
		vim.keymap.set("n", "<leader>hj", require("harpoon.ui").nav_prev, { desc = "goto prev mark" })
	end,
}
