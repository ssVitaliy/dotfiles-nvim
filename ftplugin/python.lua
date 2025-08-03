vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function()
		vim.opt_local.expandtab = true -- Convert tabs to spaces
		vim.opt_local.tabstop = 4 -- Number of spaces a tab counts for
		vim.opt_local.shiftwidth = 4 -- Number of spaces for auto-indent
		vim.opt_local.softtabstop = 4 -- Number of spaces for <Tab> and <BS>
	end,
})
