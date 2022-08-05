local options = {
  ensure_installed = { "pyright", "texlab", "clangd", "sumneko_lua" },
}

require("mason-lspconfig").setup(options)
