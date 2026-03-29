vim.lsp.config("jedi_language_server", {
	cmd = { "C:\\Users\\dimon\\home\\bin\\jedi-python-language-server\\venv\\Scripts\\jedi-language-server" },
	-- cmd = { ".\\.venv\\Scripts\\jedi-language-server" },
	filetypes = { "python" },
	root_markers = {
		"pyproject.toml",
		"setup.py",
		"setup.cfg",
		"requirements.txt",
		"Pipfile",
		".git",
	},
	init_options = {
		workspace = {
			extraPaths = { ".\\stubs" },
		},
	},
})
vim.lsp.enable("jedi_language_server")
