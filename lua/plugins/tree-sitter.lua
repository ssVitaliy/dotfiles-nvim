return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "master",
		lazy = false,
		build = ":TSUpdate",
		-- init = function(plugin)
		-- 	-- PERF: add nvim-treesitter queries to the rtp and it's custom query predicates early
		-- 	-- This is needed because a bunch of plugins no longer `require("nvim-treesitter")`, which
		-- 	-- no longer trigger the **nvim-treesitter** module to be loaded in time.
		-- 	-- Luckily, the only things that those plugins need are the custom queries, which we make available
		-- 	-- during startup.
		-- 	require("lazy.core.loader").add_to_rtp(plugin)
		-- 	require("nvim-treesitter.query_predicates")
		-- end,
		-- cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
		config = function()
			local configs = require("nvim-treesitter.configs")
			configs.setup({
				auto_install = true,
				ignore_install = {},
				modules = {},

				ensure_installed = {
					"bash",
					"c",
					"diff",
					"html",
					"lua",
					"luadoc",
					"markdown",
					"markdown_inline",
					"printf",
					"python",
					"query",
					"regex",
					"toml",
					"vim",
					"vimdoc",
					"xml",
					"yaml",
				},
				sync_install = false,
				highlight = { enable = true },
				indent = { enable = true },
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<C-space>",
						node_incremental = "<C-space>",
						scope_incremental = false,
						node_decremental = "<bs>",
					},
				},

				textobjects = {
					move = {
						enable = true,
						goto_next_start = {
							["]f"] = "@function.outer",
							["]c"] = "@class.outer",
							["]a"] = "@parameter.inner",
						},
						goto_next_end = {
							["]F"] = "@function.outer",
							["]C"] = "@class.outer",
							["]A"] = "@parameter.inner",
						},
						goto_previous_start = {
							["[f"] = "@function.outer",
							["[c"] = "@class.outer",
							["[a"] = "@parameter.inner",
						},
						goto_previous_end = {
							["[F"] = "@function.outer",
							["[C"] = "@class.outer",
							["[A"] = "@parameter.inner",
						},
					},
				},
			})
		end,
		keys = {
			{ "<c-space>", desc = "Increment Selection" },
			{ "<bs>", desc = "Decrement Selection", mode = "x" },
		},
	},
}
