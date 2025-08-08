require("options")
require("keymaps")
require("funcs.evalua_3").setup()
-- package.loaded["funcs.cd_to_file_dir"] = nil
require("funcs.cd_to_file_dir").setup()
require("lazy-init")
require("lsp.lua_ls")
require("lsp.pyright")
