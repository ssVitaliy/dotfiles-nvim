vim.api.nvim_create_user_command("AppendToDailyTips", function(opts)
	local lines = vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, false)
	local content = table.concat(lines, "\n") .. "\n\n"
	local file_name = opts.args ~= "" and opts.args or "daily_tips.txt"
	local file = io.open(file_name, "a") -- 'a' = append mode
	if not file then
		print("no file")
		return
	else
		file:write(content)
		file:close()
	end
end, { range = true, nargs = "?", complete = "file" })

vim.keymap.set({ "n", "v" }, "<leader>aa", ":AppendToDailyTips<CR>")
