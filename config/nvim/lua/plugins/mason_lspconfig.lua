require("mason-lspconfig").setup({
  ensure_installed = { "pyright", "texlab", "clangd", "lua_ls", "rust_analyzer" },
  automatic_enable = true,
})
