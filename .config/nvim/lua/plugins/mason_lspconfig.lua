local options = {
  ensure_installed = { "pyright", "texlab", "clangd", "lua_ls" },
}

require("mason-lspconfig").setup(options)
