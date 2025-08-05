vim.api.nvim_create_user_command("HTMCleanerDivSvg", function()
	-- Delete open 'div'
	vim.cmd("%s#<div.\\{-}>##g")
	-- Delete close 'div'
	vim.cmd("%s#</div>##g")
	-- Delete 'svg'
	vim.cmd("%s#<svg.*svg>##g")
end, {})
