return {
	{
		"NeogitOrg/neogit",
		dependencies = {
			"nvim-lua/plenary.nvim", -- required
			"sindrets/diffview.nvim", -- optional - Diff integration
		},
		config = function()
			local neogit = require("neogit")
			neogit.setup({
				mappings = {
					status = {
						-- Bind 'zz' in the status section to stash staged with message
						["zz"] = function()
							-- Prompt for stash name
							local stash_name = vim.fn.input("Stash name: ")
							if stash_name == "" then
								print("No stash name provided, aborted.")
								return
							end

							-- Execute: stash ONLY staged changes with the provided name
							vim.cmd("!git stash push --staged -m " .. stash_name)
							vim.notify("Staged changes stashed as: " .. stash_name, vim.log.levels.INFO)
						end,
					},
				},
			})
		end,
	},
}
