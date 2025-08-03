return {
	{
		"neovim/nvim-lspconfig",
		config = function()
			require("lspconfig").pyright.setup({
				cmd = { "pyright-langserver.cmd", "--stdio" },
				settings = {
					python = {
						analysis = {
							typeCheckingMode = "basic", -- or "strict"
							autoSearchPaths = true,
							useLibraryCodeForTypes = true,
						},
					},
				},
			})
		end,
	},
}
