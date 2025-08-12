return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		require("telescope").setup({

			defaults = {
				vimgrep_arguments = {
					"rg",
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
					"--smart-case",
					-- "--glob=!.git/",
					"--path-separator=/", -- Force rg to use forward slashes
				},
			},

			-- pickers = {
			-- find_files = { theme = "dropdown" },
			-- 	live_grep = { theme = "dropdown" },
			-- 	buffers = { theme = "dropdown" },
			-- 	help_tags = { theme = "dropdown" },
			-- },
		})

		--=== fix win backslash problem for help files search
		local original_help_tags = require("telescope.builtin").help_tags

		require("telescope.builtin").help_tags = function(opts)
			local orig_shellslash = vim.o.shellslash
			vim.o.shellslash = false -- Temporarily disable for help tags
			original_help_tags(opts)
			vim.o.shellslash = orig_shellslash -- Restore original setting
		end

		--=== Themes ===--
		local themes = require("telescope.themes")

		-- Dropdown theme (80% width)
		local common_vert = themes.get_dropdown({
			layout_strategy = "vertical",
			layout_config = {
				-- width = 0.7,
				width = function(_, max_columns, _)
					return math.min(max_columns, 88)
				end,
				height = 0.95,
				preview_height = 0.6,
				prompt_position = "top",
				anchor = "E",
			},
		})

		-- Vertical theme (narrow sidebar)
		local my_vertical = themes.get_ivy({
			layout_config = {
				width = 0.4,
				height = 0.9,
				preview_cutoff = 40,
			},
		})

		-- Horizontal theme (bottom panel)
		local my_horizontal = themes.get_dropdown({
			layout_strategy = "horizontal",
			layout_config = {
				width = 0.9,
				height = 0.3,
				prompt_position = "bottom",
			},
		})

		--=== Keys
		local builtin = require("telescope.builtin")

		-- Find files
		vim.keymap.set("n", "<leader>oo", function()
			builtin.find_files(common_vert)
		end, { desc = "Find files" })

		-- Live grep
		vim.keymap.set("n", "<leader>og", function()
			builtin.live_grep(common_vert)
		end, { desc = "Live grep" })

		-- Buffers
		vim.keymap.set("n", "<leader>ob", function()
			builtin.buffers(common_vert)
		end, { desc = "Find buffers" })

		-- Find help tags
		vim.keymap.set("n", "<leader>oh", function()
			builtin.help_tags(common_vert)
		end, { desc = "Find help" })

		-- vim.keymap.set("n", "<leader>of", builtin.find_files, { desc = "Telescope find files" })
		-- vim.keymap.set("n", "<leader>og", builtin.live_grep, { desc = "Telescope live grep" })
		-- vim.keymap.set("n", "<leader>oo", builtin.buffers, { desc = "Telescope buffers" })
		-- vim.keymap.set("n", "<leader>oh", builtin.help_tags, { desc = "Telescope help tags" })
	end,
}
