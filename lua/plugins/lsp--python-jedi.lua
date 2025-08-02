return {
	{
		"neovim/nvim-lspconfig",
		config = function()
			require("lspconfig").jedi_language_server.setup({
				cmd = {
					"C:\\Users\\dimon\\home\\bin\\jedi-python-language-server\\venv\\Scripts\\jedi-language-server.exe",
				},
				filetypes = { "python" },
				root_markers = {
					"pyproject.toml",
					"setup.py",
					"setup.cfg",
					"requirements.txt",
					"Pipfile",
					".git",
				},
			})
		end,
	},
}
