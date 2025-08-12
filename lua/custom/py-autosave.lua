vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave" }, {
	pattern = "*.py",
	callback = function()
		if vim.bo.modified and not vim.bo.readonly and vim.fn.expand("%") ~= "" then
			vim.cmd("silent! update")
		end
	end,
})
