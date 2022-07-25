local options = {
  ensure_installed = { "pyright", "texlab", "asm_lsp", "clangd", "sumneko_lua" },
}

require("mason-lspconfig").setup(options)
