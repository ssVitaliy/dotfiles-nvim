return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local telescope = require("telescope")
		local builtin = require("telescope.builtin")
		local actions = require("telescope.actions")
		local layout_strategies = require("telescope.pickers.layout_strategies")

		---=== Custom layout_strategy: merge prompt and result windows ===---
		layout_strategies.vertical_compact = function(picker, max_columns, max_lines, layout_config)
			local layout = layout_strategies.vertical(picker, max_columns, max_lines, layout_config)
			layout.results.line = layout.results.line - 1
			layout.results.height = layout.results.height + 1
			return layout
		end

		---=== Custom funcs ===---
		-- if current window x pos > 40% of screen width, return true
		local function is_right_side()
			local win_id = vim.api.nvim_get_current_win()
			local win_pos_x = vim.api.nvim_win_get_position(win_id)[2]
			local total_width = vim.o.columns
			return win_pos_x > total_width * 0.4
		end

		local function adjust_anchor(view)
			local opts = vim.deepcopy(view)

			if is_right_side() then
				opts.layout_config.anchor = "W"
			else
				opts.layout_config.anchor = "E"
			end

			return opts
		end

		telescope.setup({
			defaults = {
				vimgrep_arguments = {
					"rg",
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
					"--smart-case",
					"--path-separator=/",
				},
			},

			pickers = {
				live_grep = {
					mappings = {
						i = {
							["<C-f>"] = actions.to_fuzzy_refine,
						},
					},
				},

				find_files = {
					find_command = { "rg", "--files", "--glob", "!.git/*" },
				},
			},
		})

		--=== Fix Windows backslash problem for help tags search ===---
		do
			local original_help_tags = builtin.help_tags

			builtin.help_tags = function(opts)
				local orig_shellslash = vim.o.shellslash
				vim.o.shellslash = false

				local ok, result = xpcall(function()
					return original_help_tags(opts)
				end, debug.traceback)

				vim.o.shellslash = orig_shellslash

				if not ok then
					error(result)
				end

				return result
			end
		end

		--=== Themes ===---
		local vert_comp = {
			layout_strategy = "vertical_compact",
			sorting_strategy = "ascending",
			results_title = false,
			layout_config = {
				prompt_position = "top",
				anchor = "E",
				preview_cutoff = 1,

				width = function(_, max_columns, _)
					return math.min(max_columns, 88)
				end,

				height = function(_, _, max_lines)
					return max_lines
				end,
			},
		}

		--=== Keys ===---

		-- Find files
		vim.keymap.set("n", "<leader>ff", function()
			builtin.find_files(adjust_anchor(vert_comp))
		end, { desc = "Find files" })

		-- Live grep
		vim.keymap.set("n", "<leader>fg", function()
			builtin.live_grep(adjust_anchor(vert_comp))
		end, { desc = "Live grep" })

		-- Buffers
		vim.keymap.set("n", "<leader>fb", function()
			builtin.buffers(adjust_anchor(vert_comp))
		end, { desc = "Find buffers" })

		-- Find help tags
		vim.keymap.set("n", "<leader>fh", function()
			builtin.help_tags(adjust_anchor(vert_comp))
		end, { desc = "Find help" })

		-- Find config files
		vim.keymap.set("n", "<leader>fc", function()
			builtin.find_files(vim.tbl_deep_extend("force", adjust_anchor(vert_comp), {
				cwd = vim.fn.stdpath("config"),
			}))
		end, { desc = "Find Neovim config files" })

		-- Noteman grep search
		-- local Noteman = (project_root or cwd)/noteman
		local function get_local_noteman_dir()
			local cwd = vim.loop.cwd()

			-- если используешь git → берём root проекта
			local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]

			if vim.v.shell_error == 0 and git_root ~= "" then
				return git_root .. "/noteman"
			end

			-- fallback: просто cwd
			return cwd .. "/noteman"
		end

		local noteman_opts = vim.tbl_deep_extend("force", vert_comp, {
			search_dirs = { get_local_noteman_dir() },
		})

		local global_noteman_opts = vim.tbl_deep_extend("force", vert_comp, {
			search_dirs = { vim.fn.expand("~/noteman") },
		})

		vim.keymap.set("n", "<leader>fn", function()
			builtin.live_grep(adjust_anchor(noteman_opts))
		end, { desc = "Noteman search" })

		vim.keymap.set("n", "<leader>fN", function()
			builtin.live_grep(adjust_anchor(global_noteman_opts))
		end, { desc = "Global Noteman search" })
	end,
}
