return {
	{
		"sindrets/diffview.nvim",

		config = function()
			local actions = require("diffview.actions")
			local diffview = require("diffview")
			diffview.setup({
				use_icons = false,

				view = {
					default = {
						-- Config for changed files, and staged files in diff views.
						layout = "diff2_horizontal",
						disable_diagnostics = false, -- Temporarily disable diagnostics for diff buffers while in the view.
						winbar_info = false, -- See |diffview-config-view.x.winbar_info|
					},
					merge_tool = {
						-- Config for conflicted files in diff views during a merge or rebase.
						layout = "diff1_plain",
						disable_diagnostics = true, -- Temporarily disable diagnostics for diff buffers while in the view.
						winbar_info = true, -- See |diffview-config-view.x.winbar_info|
					},
					file_history = {
						-- Config for changed files in file history views.
						layout = "diff2_horizontal",
						disable_diagnostics = false, -- Temporarily disable diagnostics for diff buffers while in the view.
						winbar_info = false, -- See |diffview-config-view.x.winbar_info|
					},
				},

				keymaps = {
					disable_defaults = false,
					-- stylua: ignore
					view = {
						{ "n", "[[",          actions.prev_conflict,                  { desc = "In the merge-tool: jump to the previous conflict" } },
						{ "n", "]]",          actions.next_conflict,                  { desc = "In the merge-tool: jump to the next conflict" } },
						{ "n", "<leader>cu",  actions.conflict_choose("ours"),        { desc = "Choose the OURS version of a conflict" } },
						{ "n", "<leader>cl",  actions.conflict_choose("theirs"),      { desc = "Choose the THEIRS version of a conflict" } },
						{ "n", "<leader>cb",  actions.conflict_choose("base"),        { desc = "Choose the BASE version of a conflict" } },
						{ "n", "<leader>ca",  actions.conflict_choose("all"),         { desc = "Choose all the versions of a conflict" } },
						{ "n", "dx",          actions.conflict_choose("none"),        { desc = "Delete the conflict region" } },
						{ "n", "<leader>cU",  actions.conflict_choose_all("ours"),    { desc = "Choose the OURS version of a conflict for the whole file" } },
						{ "n", "<leader>cL",  actions.conflict_choose_all("theirs"),  { desc = "Choose the THEIRS version of a conflict for the whole file" } },
						{ "n", "<leader>cB",  actions.conflict_choose_all("base"),    { desc = "Choose the BASE version of a conflict for the whole file" } },
						{ "n", "<leader>cA",  actions.conflict_choose_all("all"),     { desc = "Choose all the versions of a conflict for the whole file" } },
						{ "n", "dX",          actions.conflict_choose_all("none"),    { desc = "Delete the conflict region for the whole file" } },
					},
					-- stylua: ignore
					file_pannel = {
						{ "n", "<leader>cU",     actions.conflict_choose_all("ours"),    { desc = "Choose the OURS version of a conflict for the whole file" } },
						{ "n", "<leader>cL",     actions.conflict_choose_all("theirs"),  { desc = "Choose the THEIRS version of a conflict for the whole file" } },
						{ "n", "<leader>cB",     actions.conflict_choose_all("base"),    { desc = "Choose the BASE version of a conflict for the whole file" } },
						{ "n", "<leader>cA",     actions.conflict_choose_all("all"),     { desc = "Choose all the versions of a conflict for the whole file" } },
						{ "n", "dX",             actions.conflict_choose_all("none"),    { desc = "Delete the conflict region for the whole file" } },
					},
				},
			})
		end,
	},
}
