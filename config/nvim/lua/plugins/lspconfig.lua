local capabilities = vim.lsp.protocol.make_client_capabilities()

capabilities.textDocument.completion.completionItem = {
  documentationFormat = { "markdown", "plaintext" },
  snippetSupport = true,
  preselectSupport = true,
  insertReplaceSupport = true,
  labelDetailsSupport = true,
  deprecatedSupport = true,
  commitCharactersSupport = true,
  tagSupport = { valueSet = { 1 } },
  resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  },
}

-- Defaults merged into every server configured via vim.lsp.config
vim.lsp.config("*", {
  capabilities = capabilities,
})

-- Buffer-local LSP keymaps, set whenever a server attaches
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local map = function(keys, func, desc)
      vim.keymap.set("n", keys, func, { buffer = args.buf, desc = "LSP: " .. desc })
    end

    map("gd", vim.lsp.buf.definition, "Go to Definition")
    map("gr", vim.lsp.buf.references, "Go to References")
    map("gi", vim.lsp.buf.implementation, "Go to Implementation")
    map("K", vim.lsp.buf.hover, "Hover Documentation")
    map("<leader>rn", vim.lsp.buf.rename, "Rename")
    map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
  end,
})

vim.g.rust_recommended_style = false

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
    },
  },
})

