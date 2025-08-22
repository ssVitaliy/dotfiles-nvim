return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "master",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				auto_install = false,
				ignore_install = {},
				modules = {},
				sync_install = false,

				-- stylua: ignore
				ensure_installed = { "bash", "c", "diff", "html", "lua", "luadoc", "markdown", "markdown_inline",
					"printf", "python", "query", "regex", "toml", "vim", "vimdoc", "xml", "yaml", },

				highlight = { enable = true },

				indent = { enable = true },

				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<leader>m",
						node_incremental = "<leader>m",
						node_decremental = "<leader>l",
						scope_incremental = "<leader>ms",
					},
				},
			})
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("nvim-treesitter.configs").setup({
				textobjects = {
					select = {
						enable = true,
						lookahead = true, -- Auto-jump backward
						keymaps = {
							-- Functions
							["af"] = "@function.outer",
							["if"] = "@function.inner",
							-- Classes
							["ac"] = "@class.outer",
							["ic"] = "@class.inner",
							-- Loops/blocks
							["al"] = "@loop.outer",
							["il"] = "@loop.inner",
							["ab"] = "@block.outer",
							["ib"] = "@block.inner",
							-- Parameters
							["aa"] = "@parameter.outer",
							["ia"] = "@parameter.inner",
							-- Comments
							["a/"] = "@comment.outer",
						},
					},
					swap = {
						enable = true,
						swap_next = { ["<leader>sn"] = "@parameter.inner" }, -- Swap with next parameter
						swap_previous = { ["<leader>sp"] = "@parameter.inner" }, -- Swap with previous
					},
					move = {
						enable = true,
						set_jumps = false, -- Dont add to jumplist
						goto_next_start = {
							["]f"] = "@function.outer", -- Next function start
							["]c"] = "@class.outer", -- Next class start
							["]]"] = "@parameter.inner", -- Next parameter
						},
						goto_next_end = {
							["]F"] = "@function.outer", -- Next function end
							["]C"] = "@class.outer", -- Next class end
						},
						goto_previous_start = {
							["[f"] = "@function.outer", -- Previous function start
							["[c"] = "@class.outer", -- Previous class start
							["[["] = "@parameter.inner", -- Previous parameter
						},
						goto_previous_end = {
							["[F"] = "@function.outer", -- Previous function end
							["[C"] = "@class.outer", -- Previous class end
						},
					},
				},
			})
		end,
	},
}
