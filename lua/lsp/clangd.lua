vim.lsp.config("clangd", {
	cmd = {
		"C:/Users/dimon/home/bin/clangd_20.1.8/bin/clangd.exe",
		"--background-index",
		"--clang-tidy",
		"--log=verbose",
		"--header-insertion=never",
	},
	init_options = {
		fallbackFlags = { "-std=c++17" },
	},
	root_markers = { ".clangd", "compile_commands.json" },
	filetypes = { "c", "cpp" },
})
vim.lsp.enable("clangd")
