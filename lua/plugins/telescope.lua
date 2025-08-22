return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()

		---=== Custom layout_strategie: merge prompt and result windows
		--stylua: ignore
		require("telescope.pickers.layout_strategies").vertical_compact = function(
			picker, max_columns, max_lines, layout_config)

			local layout =
				require("telescope.pickers.layout_strategies").vertical(picker, max_columns, max_lines, layout_config)
			layout.results.line = layout.results.line - 1
			layout.results.height = layout.results.height + 1
			return layout
		end

		---=== Custom funcs ===---
		-- if window x pos > 40% of width return true
		local function is_right_side()
			local win_id = vim.api.nvim_get_current_win()
			local win_pos_x = vim.api.nvim_win_get_position(win_id)[2]
			local total_width = vim.opt.columns:get()

			if win_pos_x > total_width * 0.4 then
				return true
			else
				return false
			end
		end

		local function adjust_anchor(view)
			if is_right_side() then
				view.layout_config.anchor = "W"
			else
				view.layout_config.anchor = "E"
			end
			return view
		end

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

			pickers = {
				live_grep = {
					mappings = {
						i = { ["<c-f>"] = require("telescope.actions").to_fuzzy_refine },
					},
				},
				-- find_files = { theme = "dropdown" },
				-- buffers = { theme = "dropdown" },
				-- 	help_tags = { theme = "dropdown" },
			},
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
		local vert_comp = {
			layout_strategy = "vertical_compact",
			sorting_strategy = "ascending",
			results_title = false,
			layout_config = {
				prompt_position = "top",
				anchor = "E",
				preview_cutoff = 1, -- Preview should always show (unless previewer = false)

				width = function(_, max_columns, _)
					return math.min(max_columns, 88)
				end,

				height = function(_, _, max_lines)
					return max_lines
				end,
			},
		}

		--=== Keys
		local builtin = require("telescope.builtin")

		-- Find files
		vim.keymap.set("n", "<leader>lk", function()
			builtin.find_files(adjust_anchor(vert_comp))
		end, { desc = "Find files" })

		-- Live grep
		vim.keymap.set("n", "<leader>ll", function()
			builtin.live_grep(adjust_anchor(vert_comp))
		end, { desc = "Live grep" })

		-- Buffers
		vim.keymap.set("n", "<leader>lj", function()
			builtin.buffers(adjust_anchor(vert_comp))
		end, { desc = "Find buffers" })

		-- Find help tags
		vim.keymap.set("n", "<leader>lh", function()
			builtin.help_tags(adjust_anchor(vert_comp))
		end, { desc = "Find help" })

		-- Noteman search
		local noteman_opts = vim.tbl_deep_extend("force", vert_comp, { search_dirs = { "~/noteman" } })

		vim.keymap.set("n", "<leader>ln", function()
			builtin.live_grep(noteman_opts)
		end, { desc = "Noteman search" })

		-- vim.keymap.set("n", "<leader>of", builtin.find_files, { desc = "Telescope find files" })
		-- vim.keymap.set("n", "<leader>og", builtin.live_grep, { desc = "Telescope live grep" })
		-- vim.keymap.set("n", "<leader>oo", builtin.buffers, { desc = "Telescope buffers" })
		-- vim.keymap.set("n", "<leader>oh", builtin.help_tags, { desc = "Telescope help tags" })
	end,
}
--[[
		--=== Themes ===--
		local themes = require("telescope.themes")

		local common_vert = {

			results_title = false,
			sorting_strategy = "ascending",
			layout_strategy = "vertical_compact",
			layout_config = {
				prompt_position = "top",

				anchor = "E",
				preview_cutoff = 1, -- Preview should always show (unless previewer = false)

				width = function(_, max_columns, _)
					return math.min(max_columns, 88)
				end,

				height = function(_, _, max_lines)
					return math.min(max_lines, 48)
				end,
			},
		}

		-- -- Dropdown theme (80% width)
		-- local common_vert = themes.get_dropdown({
		-- 	layout_strategy = "vertical",
		-- 	layout_config = {
		-- 		-- width = 0.7,
		-- 		width = function(_, max_columns, _)
		-- 			return math.min(max_columns, 88)
		-- 		end,
		-- 		height = 0.95,
		-- 		preview_height = 0.6,
		-- 		prompt_position = "top",
		-- 		anchor = "E",
		-- 	},
		-- })

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

--]]
